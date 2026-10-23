import Foundation
import CallKit
import AVFoundation

protocol CallKitAdapterDelegate: AnyObject {
    func callKitDidEndCall(uuid: UUID)
    func callKitDidToggleMute(muted: Bool)
    func callKitAudioSessionActivated()
    func callKitAudioSessionDeactivated()
}

final class CallKitAdapter: NSObject, CXProviderDelegate {
    static let shared = CallKitAdapter()
    private let provider: CXProvider
    private let callController = CXCallController()
    private var currentCallUUID: UUID?
    private var reportedConnected = false
    weak var delegate: CallKitAdapterDelegate?

    override init() {
        let config = CXProviderConfiguration(localizedName: "MealMate Driver")
        config.supportsVideo = false
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic]
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: .main)
    }
    func startOutgoingCall(uuid: UUID, handle: String) {
        currentCallUUID = uuid
        reportedConnected = false
        let action = CXStartCallAction(call: uuid, handle: CXHandle(type: .generic, value: handle))
        callController.request(CXTransaction(action: action)) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self, self.currentCallUUID == uuid, error != nil else { return }
                self.endCall(reason: .failed)
                self.delegate?.callKitDidEndCall(uuid: uuid)
            }
        }
    }
    func reportOutgoingCallConnected() {
        guard let uuid = currentCallUUID, !reportedConnected else { return }
        reportedConnected = true
        provider.reportOutgoingCall(with: uuid, connectedAt: Date())
    }
    func endCall(reason: CXCallEndedReason = .remoteEnded) {
        guard let uuid = currentCallUUID else { return }
        currentCallUUID = nil
        reportedConnected = false
        provider.reportCall(with: uuid, endedAt: Date(), reason: reason)
    }
    func providerDidReset(_ provider: CXProvider) {
        let uuid = currentCallUUID
        currentCallUUID = nil
        reportedConnected = false
        if let uuid = uuid { delegate?.callKitDidEndCall(uuid: uuid) }
    }
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard action.callUUID == currentCallUUID else { action.fail(); return }
        CallAudioController.shared.configureAudioSession()
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard action.callUUID == currentCallUUID else { action.fulfill(); return }
        currentCallUUID = nil
        delegate?.callKitDidEndCall(uuid: action.callUUID)
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard action.callUUID == currentCallUUID else { action.fail(); return }
        delegate?.callKitDidToggleMute(muted: action.isMuted)
        action.fulfill()
    }
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) { delegate?.callKitAudioSessionActivated() }
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) { delegate?.callKitAudioSessionDeactivated() }
}

