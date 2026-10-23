import Foundation
import WebRTC

/// The only layer touching libwebrtc; NativeWebRTCSession owns call/generation ordering.
final class WebRTCAudioPeer: NSObject, VoiceAudioPeer, RTCPeerConnectionDelegate {
    private static let initializeSSL: Void = { _ = RTCInitializeSSL() }()
    private let factory: RTCPeerConnectionFactory
    private var connection: RTCPeerConnection?
    private var audioTrack: RTCAudioTrack?
    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onFailed: (() -> Void)?
    var onCandidate: ((VoiceIceCandidate) -> Void)?
    var muted = false { didSet { audioTrack?.isEnabled = !muted } }

    init(iceServers: [IOSIceServer]) throws {
        _ = Self.initializeSSL
        factory = RTCPeerConnectionFactory(encoderFactory: nil, decoderFactory: nil)
        super.init()
        guard !iceServers.isEmpty else { throw NSError(domain: "DriverVoice", code: 1, userInfo: [NSLocalizedDescriptionKey: "No ICE servers supplied"]) }
        let config = RTCConfiguration()
        config.iceServers = iceServers.map {
            RTCIceServer(urlStrings: $0.urls, username: $0.username, credential: $0.credential)
        }
        config.sdpSemantics = .unifiedPlan
        config.bundlePolicy = .maxBundle
        config.rtcpMuxPolicy = .require
        guard let peer = factory.peerConnection(with: config, constraints: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil), delegate: self) else {
            throw NSError(domain: "DriverVoice", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create audio peer"])
        }
        connection = peer
        let source = factory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: [
            "googEchoCancellation": "true", "googNoiseSuppression": "true", "googAutoGainControl": "true"
        ], optionalConstraints: nil))
        let track = factory.audioTrack(with: source, trackId: "driver-audio")
        audioTrack = track
        guard peer.add(track, streamIds: ["driver-stream"]) != nil else {
            close()
            throw NSError(domain: "DriverVoice", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot attach microphone"])
        }
    }

    func createOffer(completion: @escaping (Result<String, Error>) -> Void) {
        guard let connection = connection else { completion(.failure(closedError)); return }
        connection.offer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)) { sdp, error in
            if let error = error { completion(.failure(error)) }
            else if let sdp = sdp { completion(.success(sdp.sdp)) }
            else { completion(.failure(NSError(domain: "DriverVoice", code: 4, userInfo: nil))) }
        }
    }
    func setLocalOffer(_ sdp: String, completion: @escaping (Error?) -> Void) {
        guard let connection = connection else { completion(closedError); return }
        connection.setLocalDescription(RTCSessionDescription(type: .offer, sdp: sdp), completionHandler: completion)
    }
    func setRemoteAnswer(_ sdp: String, completion: @escaping (Error?) -> Void) {
        guard let connection = connection else { completion(closedError); return }
        connection.setRemoteDescription(RTCSessionDescription(type: .answer, sdp: sdp), completionHandler: completion)
    }
    func addCandidate(_ candidate: VoiceIceCandidate) {
        guard let lineIndex = Int32(exactly: candidate.sdpMLineIndex), lineIndex >= 0 else { return }
        let ice = RTCIceCandidate(sdp: candidate.sdp, sdpMLineIndex: lineIndex, sdpMid: candidate.sdpMid)
        connection?.add(ice, completionHandler: { _ in })
    }
    private var closedError: NSError { NSError(domain: "DriverVoice", code: 5, userInfo: [NSLocalizedDescriptionKey: "Audio peer is closed"]) }
    func close() {
        onConnected = nil
        onDisconnected = nil
        onFailed = nil
        onCandidate = nil
        audioTrack?.isEnabled = false
        connection?.delegate = nil
        connection?.close()
        connection = nil
        audioTrack = nil
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        onCandidate?(VoiceIceCandidate(sdp: candidate.sdp, sdpMid: candidate.sdpMid, sdpMLineIndex: Int(candidate.sdpMLineIndex)))
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState) {
        switch newState {
        case .connected: onConnected?()
        case .disconnected: onDisconnected?()
        case .failed: onFailed?()
        default: break
        }
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams: [RTCMediaStream]) {
        rtpReceiver.track?.isEnabled = true
    }
}

