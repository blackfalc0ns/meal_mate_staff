import Foundation

struct VoiceIceCandidate {
    let sdp: String
    let sdpMid: String?
    let sdpMLineIndex: Int
}

protocol VoiceMediaSignaling: AnyObject {
    @discardableResult func sendOffer(callId: String, sdp: String, messageId: String, generation: Int) -> Bool
    func sendIceCandidate(callId: String, candidate: String, sdpMid: String?, sdpMLineIndex: Int?, usernameFragment: String?, messageId: String, generation: Int)
}

protocol VoiceAudioPeer: AnyObject {
    var onConnected: (() -> Void)? { get set }
    var onDisconnected: (() -> Void)? { get set }
    var onFailed: (() -> Void)? { get set }
    var onCandidate: ((VoiceIceCandidate) -> Void)? { get set }
    var muted: Bool { get set }
    func createOffer(completion: @escaping (Result<String, Error>) -> Void)
    func setLocalOffer(_ sdp: String, completion: @escaping (Error?) -> Void)
    func setRemoteAnswer(_ sdp: String, completion: @escaping (Error?) -> Void)
    func addCandidate(_ candidate: VoiceIceCandidate)
    func close()
}

protocol NativeWebRTCSessionDelegate: AnyObject {
    func webRtcLocalMediaConnected()
    func webRtcMediaDisconnected()
    func webRtcMediaFailed()
}

final class NativeWebRTCSession {
    private let signalRClient: VoiceMediaSignaling
    private let makePeer: ([IOSIceServer]) throws -> VoiceAudioPeer
    private let dispatch: (@escaping () -> Void) -> Void
    private var peer: VoiceAudioPeer?
    private var activeCallId: String?
    private var activeGeneration = 0
    private var epoch = 0
    private var muted = false
    private var connected = false
    private var remoteDescriptionSet = false
    private var answerPending = false
    private var localOffer: String?
    private var remoteCandidates: [VoiceIceCandidate] = []
    private var localCandidates: [VoiceIceCandidate] = []
    weak var delegate: NativeWebRTCSessionDelegate?

    convenience init(signalRClient: VoiceSignalRClient) {
        self.init(signalRClient: signalRClient, makePeer: { try WebRTCAudioPeer(iceServers: $0) })
    }

    init(signalRClient: VoiceMediaSignaling,
         makePeer: @escaping ([IOSIceServer]) throws -> VoiceAudioPeer,
         dispatch: @escaping (@escaping () -> Void) -> Void = { action in
             if Thread.isMainThread { action() } else { DispatchQueue.main.async(execute: action) }
         }) {
        self.signalRClient = signalRClient
        self.makePeer = makePeer
        self.dispatch = dispatch
    }

    func startOfferSession(callId: String, generation: Int, iceServers: [IOSIceServer]) {
        stop()
        activeCallId = callId
        activeGeneration = generation
        let token = epoch
        do {
            let audioPeer = try makePeer(iceServers)
            peer = audioPeer
            audioPeer.muted = muted
            audioPeer.onConnected = { [weak self] in self?.perform(token) {
                guard let self = self, !self.connected else { return }
                self.connected = true
                self.delegate?.webRtcLocalMediaConnected()
            } }
            audioPeer.onDisconnected = { [weak self] in self?.perform(token) {
                self?.connected = false
                self?.delegate?.webRtcMediaDisconnected()
            } }
            audioPeer.onFailed = { [weak self] in self?.perform(token) { self?.fail() } }
            audioPeer.onCandidate = { [weak self] candidate in self?.perform(token) {
                guard let self = self else { return }
                self.localCandidates.append(candidate)
                self.send(candidate, callId: callId)
            } }
            audioPeer.createOffer { [weak self, weak audioPeer] result in self?.perform(token) {
                guard let self = self, let audioPeer = audioPeer else { return }
                switch result {
                case .failure: self.fail()
                case .success(let sdp):
                    audioPeer.setLocalOffer(sdp) { [weak self] error in self?.perform(token) {
                        guard let self = self else { return }
                        guard error == nil else { self.fail(); return }
                        self.localOffer = sdp
                        self.resendOffer()
                    } }
                }
            } }
        } catch { fail() }
    }

    func handleRemoteAnswer(callId: String, sdp: String, generation: Int) {
        guard callId == activeCallId, generation == activeGeneration,
              !remoteDescriptionSet, !answerPending, let peer = peer else { return }
        let token = epoch
        answerPending = true
        peer.setRemoteAnswer(sdp) { [weak self, weak peer] error in self?.perform(token) {
            guard let self = self, let peer = peer else { return }
            guard error == nil else { self.fail(); return }
            self.answerPending = false
            self.remoteDescriptionSet = true
            self.remoteCandidates.forEach { peer.addCandidate($0) }
            self.remoteCandidates.removeAll()
        } }
    }

    func handleRemoteCandidate(callId: String, candidate: String, generation: Int,
                                      sdpMid: String? = nil, sdpMLineIndex: Int? = nil) {
        guard callId == activeCallId, generation == activeGeneration, !candidate.isEmpty else { return }
        let ice = VoiceIceCandidate(sdp: candidate, sdpMid: sdpMid, sdpMLineIndex: sdpMLineIndex ?? 0)
        if remoteDescriptionSet { peer?.addCandidate(ice) } else { remoteCandidates.append(ice) }
    }

    func setMuted(_ value: Bool) { muted = value; peer?.muted = value }

    func resendOffer() {
        guard let callId = activeCallId, let sdp = localOffer else { return }
        if !remoteDescriptionSet && !answerPending {
            signalRClient.sendOffer(callId: callId, sdp: sdp, messageId: UUID().uuidString, generation: activeGeneration)
        }
        localCandidates.forEach { send($0, callId: callId) }
    }

    private func send(_ candidate: VoiceIceCandidate, callId: String) {
        signalRClient.sendIceCandidate(callId: callId, candidate: candidate.sdp, sdpMid: candidate.sdpMid,
                                      sdpMLineIndex: candidate.sdpMLineIndex, usernameFragment: nil,
                                      messageId: UUID().uuidString, generation: activeGeneration)
    }
    private func perform(_ token: Int, _ action: @escaping () -> Void) {
        dispatch { [weak self] in guard self?.epoch == token else { return }; action() }
    }
    private func fail() { stop(); delegate?.webRtcMediaFailed() }
    func stop() {
        epoch += 1
        activeCallId = nil
        connected = false
        remoteDescriptionSet = false
        answerPending = false
        localOffer = nil
        remoteCandidates.removeAll()
        localCandidates.removeAll()
        let oldPeer = peer
        peer = nil
        oldPeer?.close()
    }
}

