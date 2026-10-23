import XCTest
@testable import driver_voice_engine

final class NativeWebRTCSessionTests: XCTestCase {
    private final class Peer: VoiceAudioPeer {
        var onConnected: (() -> Void)?
        var onDisconnected: (() -> Void)?
        var onFailed: (() -> Void)?
        var onCandidate: ((VoiceIceCandidate) -> Void)?
        var muted = false
        var localCompletion: ((Error?) -> Void)?
        var remoteCompletion: ((Error?) -> Void)?
        var candidates: [VoiceIceCandidate] = []
        var closed = false
        func createOffer(completion: @escaping (Result<String, Error>) -> Void) { completion(.success("generated-offer")) }
        func setLocalOffer(_ sdp: String, completion: @escaping (Error?) -> Void) { localCompletion = completion }
        func setRemoteAnswer(_ sdp: String, completion: @escaping (Error?) -> Void) { remoteCompletion = completion }
        func addCandidate(_ candidate: VoiceIceCandidate) { candidates.append(candidate) }
        func close() { closed = true }
    }
    private final class Signaling: VoiceMediaSignaling {
        var offers: [String] = []
        var candidates: [String] = []
        func sendOffer(callId: String, sdp: String, messageId: String, generation: Int) -> Bool { offers.append(sdp); return true }
        func sendIceCandidate(callId: String, candidate: String, sdpMid: String?, sdpMLineIndex: Int?, usernameFragment: String?, messageId: String, generation: Int) { candidates.append(candidate) }
    }
    private final class Delegate: NativeWebRTCSessionDelegate {
        var connected = 0
        var failed = 0
        func webRtcLocalMediaConnected() { connected += 1 }
        func webRtcMediaDisconnected() {}
        func webRtcMediaFailed() { failed += 1 }
    }
    func testAnswerDoesNotPretendAudioIsConnectedAndEarlyIceWaitsForDescription() {
        let peer = Peer(), signaling = Signaling(), delegate = Delegate()
        let session = NativeWebRTCSession(signalRClient: signaling, makePeer: { _ in peer }, dispatch: { $0() })
        session.delegate = delegate
        session.startOfferSession(callId: "call", generation: 0, iceServers: [])
        XCTAssertTrue(signaling.offers.isEmpty)
        peer.localCompletion?(nil)
        XCTAssertEqual(signaling.offers, ["generated-offer"])
        session.handleRemoteCandidate(callId: "call", candidate: "early-ice", generation: 0, sdpMid: "audio", sdpMLineIndex: 2)
        session.handleRemoteCandidate(callId: "foreign", candidate: "wrong", generation: 0)
        session.handleRemoteCandidate(callId: "call", candidate: "future", generation: 1)
        XCTAssertTrue(peer.candidates.isEmpty)
        session.handleRemoteAnswer(callId: "call", sdp: "answer", generation: 0)
        peer.remoteCompletion?(nil)
        XCTAssertEqual(peer.candidates.map { $0.sdp }, ["early-ice"])
        XCTAssertEqual(peer.candidates.first?.sdpMid, "audio")
        XCTAssertEqual(peer.candidates.first?.sdpMLineIndex, 2)
        XCTAssertEqual(delegate.connected, 0)
        peer.onConnected?()
        peer.onConnected?()
        XCTAssertEqual(delegate.connected, 1)
    }
    func testRebindReplaysCandidatesAndMuteAndStopControlActualPeer() {
        let peer = Peer(), signaling = Signaling(), delegate = Delegate()
        let session = NativeWebRTCSession(signalRClient: signaling, makePeer: { _ in peer }, dispatch: { $0() })
        session.delegate = delegate
        session.startOfferSession(callId: "call", generation: 0, iceServers: [])
        peer.localCompletion?(nil)
        peer.onCandidate?(VoiceIceCandidate(sdp: "local-ice", sdpMid: "0", sdpMLineIndex: 0))
        session.resendOffer()
        XCTAssertEqual(signaling.offers, ["generated-offer", "generated-offer"])
        XCTAssertEqual(signaling.candidates, ["local-ice", "local-ice"])
        session.setMuted(true)
        XCTAssertTrue(peer.muted)
        let lateConnected = peer.onConnected
        session.stop()
        XCTAssertTrue(peer.closed)
        lateConnected?()
        XCTAssertEqual(delegate.connected, 0)
    }
}
