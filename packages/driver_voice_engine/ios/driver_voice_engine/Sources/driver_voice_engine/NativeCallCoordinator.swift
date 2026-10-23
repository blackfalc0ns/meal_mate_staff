import Foundation
import CallKit

final class NativeCallCoordinator: VoiceSignalRListener, NativeWebRTCSessionDelegate, CallKitAdapterDelegate {
    static let shared = NativeCallCoordinator()
    let store = VoiceCallStore.shared
    lazy var apiClient = VoiceAPIClient(store: store)
    lazy var sessionManager = VoiceSessionManager(store: store, apiClient: apiClient)
    lazy var signalRClient = VoiceSignalRClient(store: store, apiClient: apiClient)
    let ringbackPlayer = RingbackPlayer()
    let proximityController = ProximityController()
    let audioController = CallAudioController.shared
    let callKitAdapter = CallKitAdapter.shared
    lazy var webRtcSession = NativeWebRTCSession(signalRClient: signalRClient)
    var flutterApi: DriverVoiceFlutterApiProtocol?

    private let engineInstanceId = UUID().uuidString
    private var localRevision = 0
    private var currentOperationId = ""
    private var activeCallId: String?
    private var activeTripStopId = ""
    private var activeClientRequestId = ""
    private var serverSequence = 0
    private var negotiationGeneration = 0
    private var offerGeneration: Int?
    private var serverStatus: DriverVoiceServerCallStatus = .idle
    private var mediaState: DriverVoiceMediaState = .idle
    private var connectedAtUtc: String?
    private var deadlineAtUtc: String?
    private var isMuted = false
    private var currentRoute: DriverVoiceAudioRoute = .earpiece
    private var terminationReason: DriverVoiceTerminationReason = .none
    private var serverEndPending = false
    private var heartbeatTimer: Timer?
    private var reconcileWork: DispatchWorkItem?
    private var snapshotInFlight = false

    init() {
        signalRClient.listener = self
        webRtcSession.delegate = self
        callKitAdapter.delegate = self
    }
    private func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread { action() } else { DispatchQueue.main.async(execute: action) }
    }
    func getCurrentSnapshot() -> DriverVoiceCallSnapshot {
        DriverVoiceCallSnapshot(schemaVersion: 1, engineInstanceId: engineInstanceId, localRevision: Int64(localRevision),
            operationId: currentOperationId, callId: activeCallId, tripStopId: activeTripStopId, serverSequence: Int64(serverSequence),
            generation: Int64(negotiationGeneration), serverStatus: serverStatus, mediaState: mediaState,
            connectedAtUtc: connectedAtUtc, deadlineAtUtc: deadlineAtUtc, muted: isMuted, audioRoute: currentRoute,
            availableRoutes: [.earpiece, .speaker], interruptionState: .none, terminationReason: terminationReason,
            serverEndPending: serverEndPending)
    }
    func startOutgoing(request: DriverVoiceStartOutgoingRequest, completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void) {
        guard serverStatus == .idle || isTerminal(serverStatus) else {
            completion(.success(DriverVoiceCommandResult(status: .busy, errorMessage: "Another call is active"))); return
        }
        currentOperationId = UUID().uuidString
        let operation = currentOperationId
        let tripStopId = request.tripStopId
        let clientRequestId = request.clientRequestId
        activeTripStopId = tripStopId
        activeClientRequestId = clientRequestId
        activeCallId = nil
        serverSequence = 0
        negotiationGeneration = 0
        offerGeneration = nil
        serverStatus = .created
        mediaState = .preparing
        connectedAtUtc = nil
        deadlineAtUtc = nil
        terminationReason = .none
        serverEndPending = false
        isMuted = false
        currentRoute = .earpiece
        webRtcSession.setMuted(false)
        reconcileWork?.cancel()
        snapshotInFlight = false
        incrementRevisionAndNotify()
        callKitAdapter.startOutgoingCall(uuid: UUID(), handle: request.displayMetadata?.customerName ?? "Customer")
        sessionManager.ensureSession { [weak self] ready in self?.onMain {
            guard let self = self else { return }
            guard self.isCurrent(operation) else { completion(.success(self.cancelledStart())); return }
            guard ready else {
                self.transitionToFailed()
                completion(.success(DriverVoiceCommandResult(status: .preparationFailed, errorMessage: "Voice session registration failed"))); return
            }
            self.signalRClient.connectWhenBound { [weak self] bound in
                guard let self = self else { return }
                guard self.isCurrent(operation) else { completion(.success(self.cancelledStart())); return }
                guard bound else {
                    self.transitionToFailed()
                    completion(.success(DriverVoiceCommandResult(status: .preparationFailed, errorMessage: "Voice signaling could not be bound"))); return
                }
                self.apiClient.initiateCall(tripStopId: tripStopId, clientRequestId: clientRequestId) { [weak self] result in self?.onMain {
                    guard let self = self else { return }
                    guard self.isCurrent(operation) else {
                        if case .success(let response) = result {
                            if ["created", "ringing"].contains(response.status.lowercased()) {
                                self.apiClient.cancelCall(callId: response.callId) { [weak self] cancelled in
                                    if !cancelled { self?.apiClient.endCall(callId: response.callId) { _ in } }
                                }
                            } else { self.apiClient.endCall(callId: response.callId) { _ in } }
                        }
                        completion(.success(self.cancelledStart())); return
                    }
                    switch result {
                    case .failure(let error):
                        self.transitionToFailed()
                        completion(.success(DriverVoiceCommandResult(status: .ambiguousInitiation, errorMessage: error.localizedDescription)))
                    case .success(let response):
                        self.activeCallId = response.callId
                        self.store.saveCallReconciliation(callId: response.callId, tripStopId: tripStopId, clientRequestId: clientRequestId, endPending: false)
                        self.applySnapshot(response)
                        self.reconcileNow()
                        completion(.success(DriverVoiceCommandResult(status: .success, operationId: operation)))
                    }
                } }
            }
        } }
    }
    private func cancelledStart() -> DriverVoiceCommandResult {
        DriverVoiceCommandResult(status: .preparationFailed, errorMessage: "Call was cancelled or superseded")
    }
    private func isCurrent(_ operation: String) -> Bool { operation == currentOperationId && !isTerminal(serverStatus) }
    private func applySnapshot(_ snapshot: IOSCallSnapshotResponse) {
        guard snapshot.callId == activeCallId, !isTerminal(serverStatus), snapshot.sequence >= serverSequence else { return }
        serverSequence = snapshot.sequence
        connectedAtUtc = snapshot.connectedAtUtc ?? connectedAtUtc
        deadlineAtUtc = snapshot.deadlineAtUtc
        updateStatus(snapshot.status)
        incrementRevisionAndNotify()
    }
    private func updateStatus(_ status: String) {
        switch status.lowercased() {
        case "ringing":
            guard serverStatus == .created || serverStatus == .ringing else { return }
            serverStatus = .ringing
            ringbackPlayer.start()
            proximityController.enable()
        case "accepted", "connecting":
            if serverStatus != .active { serverStatus = .accepted }
            ringbackPlayer.stop()
            startWebRtcOffer()
        case "active", "incall":
            serverStatus = .active
            ringbackPlayer.stop()
            startWebRtcOffer()
            callKitAdapter.reportOutgoingCallConnected()
            if heartbeatTimer == nil { startHeartbeat() }
        case "cancelled": handleTerminal(.cancelled, .cancelled)
        case "rejected": handleTerminal(.rejected, .rejected)
        case "missed": handleTerminal(.missed, .missed)
        case "ended": handleTerminal(.ended, .remoteHangup)
        case "failed": handleTerminal(.failed, .networkFailure)
        case "busy": handleTerminal(.busy, .rejected)
        default: break
        }
    }
    func setMuted(muted: Bool, completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void) {
        isMuted = muted
        webRtcSession.setMuted(muted)
        incrementRevisionAndNotify()
        completion(.success(DriverVoiceCommandResult(status: .success)))
    }
    func selectAudioRoute(route: DriverVoiceAudioRoute, completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void) {
        currentRoute = route
        audioController.selectAudioRoute(route)
        if route == .earpiece { proximityController.enable() } else { proximityController.disable() }
        incrementRevisionAndNotify()
        completion(.success(DriverVoiceCommandResult(status: .success)))
    }
    func hangUp(reason: String?, completion: ((Result<DriverVoiceCommandResult, Error>) -> Void)? = nil) {
        guard !isTerminal(serverStatus), serverStatus != .idle else {
            completion?(.success(DriverVoiceCommandResult(status: .success))); return
        }
        let callId = activeCallId
        let operation = currentOperationId
        let early = serverStatus == .created || serverStatus == .ringing
        handleTerminal(early ? .cancelled : .ended, .localHangup)
        guard let callId = callId else { completion?(.success(DriverVoiceCommandResult(status: .success))); return }
        serverEndPending = true
        incrementRevisionAndNotify()
        let finish: (Bool) -> Void = { [weak self] success in self?.onMain {
            guard let self = self else { return }
            if self.currentOperationId == operation {
                self.serverEndPending = !success
                self.incrementRevisionAndNotify()
            }
            completion?(.success(DriverVoiceCommandResult(status: .success)))
        } }
        if early { apiClient.cancelCall(callId: callId, completion: finish) }
        else { apiClient.endCall(callId: callId, completion: finish) }
    }
    private func handleTerminal(_ status: DriverVoiceServerCallStatus, _ reason: DriverVoiceTerminationReason) {
        serverStatus = status
        mediaState = .disconnected
        terminationReason = reason
        ringbackPlayer.stop()
        proximityController.disable()
        webRtcSession.stop()
        audioController.stopAudio()
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        reconcileWork?.cancel()
        reconcileWork = nil
        snapshotInFlight = false
        callKitAdapter.endCall(reason: status == .failed ? .failed : .remoteEnded)
        incrementRevisionAndNotify()
    }
    private func transitionToFailed() { handleTerminal(.failed, .error) }
    private func isTerminal(_ status: DriverVoiceServerCallStatus) -> Bool {
        [.ended, .cancelled, .rejected, .missed, .failed, .busy].contains(status)
    }
    private func startWebRtcOffer() {
        guard let callId = activeCallId, offerGeneration != negotiationGeneration else { return }
        let operation = currentOperationId
        let generation = negotiationGeneration
        offerGeneration = generation
        mediaState = .connecting
        signalRClient.connectWhenBound { [weak self] bound in
            guard let self = self, self.isCurrent(operation), self.activeCallId == callId, self.negotiationGeneration == generation else { return }
            guard bound else { self.webRtcMediaFailed(); return }
            self.apiClient.getIceServers(callId: callId) { [weak self] servers in self?.onMain {
                guard let self = self, self.isCurrent(operation), self.activeCallId == callId, self.negotiationGeneration == generation else { return }
                guard let servers = servers, !servers.isEmpty else { self.webRtcMediaFailed(); return }
                self.apiClient.reportConnecting(callId: callId) { _ in }
                self.audioController.selectAudioRoute(self.currentRoute)
                self.webRtcSession.startOfferSession(callId: callId, generation: generation, iceServers: servers)
            } }
        }
    }
    private func startHeartbeat() {
        guard let callId = activeCallId else { return }
        let operation = currentOperationId
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            guard let self = self, self.isCurrent(operation), self.serverStatus == .active else { return }
            self.apiClient.sendHeartbeat(callId: callId) { _ in }
        }
    }
    private func reconcileNow() {
        guard let callId = activeCallId, !isTerminal(serverStatus), !snapshotInFlight else { return }
        reconcileWork?.cancel()
        reconcileWork = nil
        snapshotInFlight = true
        let operation = currentOperationId
        apiClient.getCallSnapshot(callId: callId) { [weak self] snapshot in self?.onMain {
            guard let self = self, self.isCurrent(operation), self.activeCallId == callId else { return }
            self.snapshotInFlight = false
            if let snapshot = snapshot { self.applySnapshot(snapshot) }
            guard !self.isTerminal(self.serverStatus) else { return }
            let work = DispatchWorkItem { [weak self] in self?.reconcileNow() }
            self.reconcileWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.serverStatus == .active ? 10 : 2), execute: work)
        } }
    }
    private func incrementRevisionAndNotify() {
        localRevision += 1
        flutterApi?.onSnapshotUpdated(snapshot: getCurrentSnapshot()) { _ in }
    }
    func onBound() { webRtcSession.resendOffer(); reconcileNow() }
    func onConnectionStateChanged(connected: Bool) {}
    func onCallEvent(envelope: [String: Any]) {
        guard envelope["callId"] as? String == activeCallId, !isTerminal(serverStatus) else { return }
        let payload = envelope["payload"] as? [String: Any]
        guard let status = payload?["status"] as? String ?? envelope["status"] as? String else { return }
        let sequence = envelope["sequence"] as? Int ?? 0
        guard sequence == 0 || sequence > serverSequence else { return }
        if sequence > 0 { serverSequence = sequence }
        if let generation = envelope["negotiationGeneration"] as? Int, generation > negotiationGeneration {
            negotiationGeneration = generation
            offerGeneration = nil
            webRtcSession.stop()
        }
        connectedAtUtc = payload?["connectedAtUtc"] as? String ?? connectedAtUtc
        updateStatus(status)
        incrementRevisionAndNotify()
    }
    func onOffer(callId: String, sdp: String, messageId: String, generation: Int) {}
    func onAnswer(callId: String, sdp: String, messageId: String, generation: Int) {
        guard callId == activeCallId, generation == negotiationGeneration, !isTerminal(serverStatus) else { return }
        ringbackPlayer.stop()
        webRtcSession.handleRemoteAnswer(callId: callId, sdp: sdp, generation: generation)
    }
    func onIceCandidate(callId: String, candidate: String, sdpMid: String?, sdpMLineIndex: Int?, usernameFragment: String?, messageId: String, generation: Int) {
        guard !isTerminal(serverStatus) else { return }
        webRtcSession.handleRemoteCandidate(callId: callId, candidate: candidate, generation: generation, sdpMid: sdpMid, sdpMLineIndex: sdpMLineIndex)
    }
    func webRtcLocalMediaConnected() {
        guard let callId = activeCallId, !isTerminal(serverStatus) else { return }
        ringbackPlayer.stop()
        mediaState = .connected
        incrementRevisionAndNotify()
        apiClient.reportConnected(callId: callId) { [weak self] _ in self?.onMain { self?.reconcileNow() } }
    }
    func webRtcMediaDisconnected() {
        guard !isTerminal(serverStatus) else { return }
        mediaState = .reconnecting
        incrementRevisionAndNotify()
    }
    func webRtcMediaFailed() {
        guard !isTerminal(serverStatus) else { return }
        let callId = activeCallId
        handleTerminal(.failed, .networkFailure)
        if let callId = callId { apiClient.endCall(callId: callId) { _ in } }
    }
    func callKitDidEndCall(uuid: UUID) { hangUp(reason: "callkit_user_end") }
    func callKitDidToggleMute(muted: Bool) { setMuted(muted: muted) { _ in } }
    func callKitAudioSessionActivated() {
        audioController.activateAudioSession()
        if isTerminal(serverStatus) || serverStatus == .idle { audioController.stopAudio() }
        else { audioController.selectAudioRoute(currentRoute) }
    }
    func callKitAudioSessionDeactivated() { audioController.deactivateAudioSession() }
}

