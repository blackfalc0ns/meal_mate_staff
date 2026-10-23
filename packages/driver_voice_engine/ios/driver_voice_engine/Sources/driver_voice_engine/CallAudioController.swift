import Foundation
import AVFoundation
import WebRTC

final class CallAudioController {
    static let shared = CallAudioController()
    private let rtcSession = RTCAudioSession.sharedInstance()
    init() {}

    func configureAudioSession() {
        rtcSession.useManualAudio = true
        rtcSession.isAudioEnabled = false
        rtcSession.lockForConfiguration()
        defer { rtcSession.unlockForConfiguration() }
        do {
            let config = RTCAudioSessionConfiguration.webRTC()
            config.category = AVAudioSession.Category.playAndRecord.rawValue
            config.mode = AVAudioSession.Mode.voiceChat.rawValue
            config.categoryOptions = [.allowBluetooth, .duckOthers]
            try rtcSession.setConfiguration(config)
        } catch { NSLog("[DriverVoice] Audio configuration failed: %@", error.localizedDescription) }
    }
    // CallKit owns activation. Forward its notifications instead of activating a second time.
    func activateAudioSession() {
        rtcSession.audioSessionDidActivate(AVAudioSession.sharedInstance())
        rtcSession.isAudioEnabled = true
    }
    func deactivateAudioSession() {
        rtcSession.isAudioEnabled = false
        rtcSession.audioSessionDidDeactivate(AVAudioSession.sharedInstance())
    }
    func stopAudio() { rtcSession.isAudioEnabled = false }
    func selectAudioRoute(_ route: DriverVoiceAudioRoute) {
        rtcSession.lockForConfiguration()
        defer { rtcSession.unlockForConfiguration() }
        do { try rtcSession.overrideOutputAudioPort(route == .speaker ? .speaker : .none) }
        catch { NSLog("[DriverVoice] Audio route failed: %@", error.localizedDescription) }
    }
}

