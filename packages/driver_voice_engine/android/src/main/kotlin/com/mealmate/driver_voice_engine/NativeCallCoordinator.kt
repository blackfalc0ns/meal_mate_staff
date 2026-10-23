package com.mealmate.driver_voice_engine

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import kotlinx.coroutines.*
import org.json.JSONObject
import java.util.UUID

class NativeCallCoordinator(private val context: Context, private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO) : VoiceSignalRClient.Listener, NativeWebRtcSession.Listener {

    companion object {
        private const val TAG = "NativeCallCoordinator"
        @Volatile
        private var instance: NativeCallCoordinator? = null

        fun getInstance(context: Context): NativeCallCoordinator {
            return instance ?: synchronized(this) {
                instance ?: NativeCallCoordinator(context.applicationContext).also { instance = it }
            }
        }
    }

    val store = VoiceCallStore(context)
    val apiClient = VoiceApiClient(store)
    val sessionManager = VoiceSessionManager(store, apiClient)
    val signalRClient = VoiceSignalRClient(store, apiClient) { onSignalRReconnected() }
    val ringbackPlayer = RingbackPlayer(context)
    val proximityController = ProximityController(context)
    val telecomAdapter = TelecomCallAdapter(context)
    val webRtcSession = NativeWebRtcSession(context, signalRClient)

    var flutterApi: DriverVoiceFlutterApi? = null
    var currentCustomerName: String? = null

    private val engineInstanceId = UUID.randomUUID().toString()
    private var localRevision = 0
    private var currentOperationId: String = ""
    private var activeCallId: String? = null
    private var activeTripStopId: String = ""
    private var activeClientRequestId: String = ""
    private var serverSequence = 0
    private var negotiationGeneration = 0
    private var serverStatus = DriverVoiceServerCallStatus.IDLE
    private var mediaState = DriverVoiceMediaState.IDLE
    private var connectedAtUtc: String? = null
    private var deadlineAtUtc: String? = null
    private var isMuted = false
    private var currentRoute = DriverVoiceAudioRoute.EARPIECE
    private var terminationReason = DriverVoiceTerminationReason.NONE
    private var serverEndPending = false

    private val mainHandler = Handler(Looper.getMainLooper())
    private val coordinatorScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var heartbeatJob: Job? = null
    private var deadlineJob: Job? = null
    private var reconciliationJob: Job? = null
    private var offerStarted = false

    init {
        signalRClient.listener = this
        webRtcSession.listener = this
    }

    fun getCurrentSnapshot(): DriverVoiceCallSnapshot {
        return DriverVoiceCallSnapshot(
            schemaVersion = 1,
            engineInstanceId = engineInstanceId,
            localRevision = localRevision.toLong(),
            operationId = currentOperationId,
            callId = activeCallId,
            tripStopId = activeTripStopId,
            serverSequence = serverSequence.toLong(),
            generation = negotiationGeneration.toLong(),
            serverStatus = serverStatus,
            mediaState = mediaState,
            connectedAtUtc = connectedAtUtc,
            deadlineAtUtc = deadlineAtUtc,
            muted = isMuted,
            audioRoute = currentRoute,
            availableRoutes = listOf(DriverVoiceAudioRoute.EARPIECE, DriverVoiceAudioRoute.SPEAKER),
            interruptionState = DriverVoiceInterruptionState.NONE,
            terminationReason = terminationReason,
            serverEndPending = serverEndPending
        )
    }

    fun startOutgoing(
        request: DriverVoiceStartOutgoingRequest,
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        if (serverStatus != DriverVoiceServerCallStatus.IDLE && !isTerminal(serverStatus)) {
            callback(Result.success(DriverVoiceCommandResult(
                status = DriverVoiceCommandStatus.BUSY,
                errorMessage = "Another call is currently active"
            )))
            return
        }

        currentOperationId = UUID.randomUUID().toString()
        val operationId = currentOperationId
        activeTripStopId = request.tripStopId
        activeClientRequestId = request.clientRequestId
        currentCustomerName = request.displayMetadata?.customerName ?: "Customer"
        activeCallId = null
        serverSequence = 0
        negotiationGeneration = 0
        serverStatus = DriverVoiceServerCallStatus.CREATED
        mediaState = DriverVoiceMediaState.PREPARING
        connectedAtUtc = null
        deadlineAtUtc = null
        terminationReason = DriverVoiceTerminationReason.NONE
        serverEndPending = false
        offerStarted = false
        isMuted = false
        webRtcSession.setMuted(false)
        reconciliationJob?.cancel()
        incrementRevisionAndNotify()

        // Start Android Foreground Service immediately
        VoiceCallService.start(context)

        coordinatorScope.launch(ioDispatcher) {
            try {
                // Ensure native voice device session
                val sessionReady = sessionManager.ensureSession()
                if (!sessionReady) {
                    withContext(Dispatchers.Main) {
                        transitionToFailed("Voice session registration failed")
                        callback(Result.success(DriverVoiceCommandResult(
                            status = DriverVoiceCommandStatus.PREPARATION_FAILED,
                            errorMessage = "Voice device session registration failed"
                        )))
                    }
                    return@launch
                }

                // Connect SignalR
                check(signalRClient.connectAndAwaitBound()) { "Voice signaling session could not be bound" }
                withContext(Dispatchers.Main) {
                    check(currentOperationId == operationId && !isTerminal(serverStatus)) { "Call was cancelled" }
                }

                // Initiate call via REST
                val response = apiClient.initiateCall(
                    tripStopId = activeTripStopId,
                    clientRequestId = activeClientRequestId
                )

                withContext(Dispatchers.Main) {
                    if (currentOperationId != operationId || isTerminal(serverStatus)) {
                        Log.w(TAG, "Operation ID changed during initiate, ignoring result")
                        coordinatorScope.launch(ioDispatcher) { response?.let { apiClient.cancelCall(it.callId) } }
                        callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.PREPARATION_FAILED)))
                        return@withContext
                    }

                    if (response == null) {
                        transitionToFailed("Initiate call failed or timed out")
                        callback(Result.success(DriverVoiceCommandResult(
                            status = DriverVoiceCommandStatus.AMBIGUOUS_INITIATION,
                            errorMessage = "Call initiate failed"
                        )))
                        return@withContext
                    }

                    activeCallId = response.callId
                    serverSequence = response.sequence
                    deadlineAtUtc = response.deadlineAtUtc
                    store.saveCallReconciliation(
                        callId = response.callId,
                        tripStopId = activeTripStopId,
                        clientRequestId = activeClientRequestId,
                        endPending = false
                    )

                    updateStatusFromRest(response.status)
                    startReconciliation(response.callId, operationId)
                    incrementRevisionAndNotify()

                    callback(Result.success(DriverVoiceCommandResult(
                        status = DriverVoiceCommandStatus.SUCCESS,
                        operationId = operationId
                    )))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    if (currentOperationId == operationId && !isTerminal(serverStatus)) transitionToFailed(e.message ?: "Unknown start error")
                    callback(Result.success(DriverVoiceCommandResult(
                        status = DriverVoiceCommandStatus.PREPARATION_FAILED,
                        errorMessage = e.message
                    )))
                }
            }
        }
    }

    private fun updateStatusFromRest(statusStr: String) {
        when (statusStr.lowercase()) {
            "ringing" -> {
                serverStatus = DriverVoiceServerCallStatus.RINGING
                ringbackPlayer.start()
                proximityController.enable()
                updateNotification("Ringing...")
            }
            "accepted", "connecting" -> {
                serverStatus = DriverVoiceServerCallStatus.ACCEPTED
                ringbackPlayer.stop()
                updateNotification("Accepted...")
                startWebRtcOffer()
            }
            "active", "incall" -> {
                serverStatus = DriverVoiceServerCallStatus.ACTIVE
                ringbackPlayer.stop()
                startWebRtcOffer()
                if (heartbeatJob?.isActive != true) startHeartbeat()
                updateNotification("Call in progress")
            }
            "cancelled" -> handleTerminal(DriverVoiceServerCallStatus.CANCELLED, DriverVoiceTerminationReason.CANCELLED)
            "rejected" -> handleTerminal(DriverVoiceServerCallStatus.REJECTED, DriverVoiceTerminationReason.REJECTED)
            "missed" -> handleTerminal(DriverVoiceServerCallStatus.MISSED, DriverVoiceTerminationReason.MISSED)
            "ended" -> handleTerminal(DriverVoiceServerCallStatus.ENDED, DriverVoiceTerminationReason.REMOTE_HANGUP)
            "failed" -> handleTerminal(DriverVoiceServerCallStatus.FAILED, DriverVoiceTerminationReason.NETWORK_FAILURE)
            "busy" -> handleTerminal(DriverVoiceServerCallStatus.BUSY, DriverVoiceTerminationReason.REJECTED)
        }
    }

    fun setMuted(muted: Boolean, callback: (Result<DriverVoiceCommandResult>) -> Unit) {
        isMuted = muted
        webRtcSession.setMuted(muted)
        telecomAdapter.setMuted(muted)
        incrementRevisionAndNotify()
        callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.SUCCESS)))
    }

    fun toggleMute() {
        setMuted(!isMuted) {}
    }

    fun selectAudioRoute(route: DriverVoiceAudioRoute, callback: (Result<DriverVoiceCommandResult>) -> Unit) {
        currentRoute = route
        telecomAdapter.selectAudioRoute(route)
        if (route == DriverVoiceAudioRoute.EARPIECE) {
            proximityController.enable()
        } else {
            proximityController.disable()
        }
        incrementRevisionAndNotify()
        callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.SUCCESS)))
    }

    fun hangUp(reason: String?, callback: ((Result<DriverVoiceCommandResult>) -> Unit)? = null) {
        val callId = activeCallId
        ringbackPlayer.stop()
        proximityController.disable()
        webRtcSession.stop()
        stopHeartbeat()
        reconciliationJob?.cancel()
        reconciliationJob = null

        val isEarly = serverStatus == DriverVoiceServerCallStatus.CREATED || serverStatus == DriverVoiceServerCallStatus.RINGING
        val targetStatus = if (isEarly) DriverVoiceServerCallStatus.CANCELLED else DriverVoiceServerCallStatus.ENDED
        val termReason = DriverVoiceTerminationReason.LOCAL_HANGUP

        handleTerminal(targetStatus, termReason)
        serverEndPending = true
        incrementRevisionAndNotify()

        coordinatorScope.launch(ioDispatcher) {
            if (callId != null) {
                if (isEarly) {
                    apiClient.cancelCall(callId)
                } else {
                    apiClient.endCall(callId)
                }
            }
            withContext(Dispatchers.Main) {
                serverEndPending = false
                incrementRevisionAndNotify()
                callback?.invoke(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.SUCCESS)))
            }
        }
    }

    private fun handleTerminal(status: DriverVoiceServerCallStatus, reason: DriverVoiceTerminationReason) {
        serverStatus = status
        mediaState = DriverVoiceMediaState.DISCONNECTED
        terminationReason = reason
        ringbackPlayer.stop()
        proximityController.disable()
        webRtcSession.stop()
        stopHeartbeat()
        telecomAdapter.cancelNotification()
        telecomAdapter.releaseAudio()
        VoiceCallService.stop(context)
        incrementRevisionAndNotify()
    }

    fun terminateLocalSession() {
        deadlineJob?.cancel()
        deadlineJob = null
        reconciliationJob?.cancel()
        reconciliationJob = null
        currentOperationId = UUID.randomUUID().toString()
        handleTerminal(DriverVoiceServerCallStatus.FAILED, DriverVoiceTerminationReason.ERROR)
        signalRClient.disconnect()
        store.clearAll()
    }

    suspend fun reconcileSession() {
        if (serverStatus == DriverVoiceServerCallStatus.IDLE || isTerminal(serverStatus)) return
        val callId = activeCallId ?: return
        signalRClient.connectAndAwaitBound()
        val snapshot = apiClient.getCallSnapshot(callId) ?: return
        withContext(Dispatchers.Main) {
            if (activeCallId == snapshot.callId && snapshot.sequence >= serverSequence) {
                updateStatusFromRest(snapshot.status)
                serverSequence = snapshot.sequence
                incrementRevisionAndNotify()
            }
        }
    }

    private fun transitionToFailed(errorMessage: String) {
        Log.e(TAG, "Call transition to failed: $errorMessage")
        handleTerminal(DriverVoiceServerCallStatus.FAILED, DriverVoiceTerminationReason.ERROR)
    }

    private fun isTerminal(status: DriverVoiceServerCallStatus): Boolean {
        return status == DriverVoiceServerCallStatus.ENDED ||
                status == DriverVoiceServerCallStatus.CANCELLED ||
                status == DriverVoiceServerCallStatus.REJECTED ||
                status == DriverVoiceServerCallStatus.MISSED ||
                status == DriverVoiceServerCallStatus.FAILED ||
                status == DriverVoiceServerCallStatus.BUSY
    }

    private fun startWebRtcOffer() {
        val callId = activeCallId ?: return
        if (offerStarted) return
        offerStarted = true
        mediaState = DriverVoiceMediaState.CONNECTING
        val operationId = currentOperationId
        coordinatorScope.launch(ioDispatcher) {
            val signalingReady = signalRClient.connectAndAwaitBound()
            if (!signalingReady) {
                withContext(Dispatchers.Main) {
                    if (currentOperationId == operationId && !isTerminal(serverStatus)) onMediaFailed()
                }
                return@launch
            }
            val iceServers = apiClient.getIceServers(callId)
            apiClient.reportConnecting(callId)
            withContext(Dispatchers.Main) {
                if (currentOperationId != operationId || activeCallId != callId || isTerminal(serverStatus)) return@withContext
                if (iceServers.isNullOrEmpty()) {
                    onMediaFailed()
                    return@withContext
                }
                telecomAdapter.selectAudioRoute(currentRoute)
                webRtcSession.startOfferSession(callId, negotiationGeneration, iceServers)
            }
        }
    }

    private fun startHeartbeat() {
        stopHeartbeat()
        val callId = activeCallId ?: return
        heartbeatJob = coordinatorScope.launch(ioDispatcher) {
            while (isActive && serverStatus == DriverVoiceServerCallStatus.ACTIVE) {
                delay(15000)
                apiClient.sendHeartbeat(callId)
            }
        }
    }

    private fun stopHeartbeat() {
        heartbeatJob?.cancel()
        heartbeatJob = null
    }

    private fun updateNotification(statusText: String) {
        val callId = activeCallId ?: return
        val notif = telecomAdapter.buildCallNotification(
            callId = callId,
            customerName = currentCustomerName ?: "Customer",
            statusText = statusText,
            isMuted = isMuted,
            connectedAtUtcMs = null
        )
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        nm.notify(TelecomCallAdapter.NOTIFICATION_ID, notif)
    }

    private fun incrementRevisionAndNotify() {
        localRevision++
        val snapshot = getCurrentSnapshot()
        flutterApi?.onSnapshotUpdated(snapshot) {}
    }

    // VoiceSignalRClient.Listener
    override fun onBound() {
        Log.i(TAG, "SignalR bound successfully")
        coordinatorScope.launch(Dispatchers.Main) { webRtcSession.resendOffer() }
        onSignalRReconnected()
    }

    override fun onCallEvent(envelope: JSONObject) {
        coordinatorScope.launch(Dispatchers.Main) {
            if (envelope.optString("callId") != activeCallId || isTerminal(serverStatus)) return@launch
            val payload = envelope.optJSONObject("payload")
            val statusStr = payload?.optString("status")?.takeIf { it.isNotBlank() }
                ?: envelope.optString("status").takeIf { it.isNotBlank() }
                ?: return@launch
            val seq = envelope.optInt("sequence", 0)
            if (seq in 1..serverSequence) return@launch
            if (seq > 0) serverSequence = seq
            negotiationGeneration = envelope.optInt("negotiationGeneration", negotiationGeneration)
            connectedAtUtc = payload?.optString("connectedAtUtc")?.takeIf { it.isNotBlank() && it != "null" } ?: connectedAtUtc
            updateStatusFromRest(statusStr)
            incrementRevisionAndNotify()
        }
    }

    override fun onOffer(callId: String, sdp: String, messageId: String, generation: Int) {}

    override fun onAnswer(callId: String, sdp: String, messageId: String, generation: Int) {
        coordinatorScope.launch(Dispatchers.Main) {
            if (callId != activeCallId || generation != negotiationGeneration || isTerminal(serverStatus)) return@launch
            ringbackPlayer.stop()
            webRtcSession.handleRemoteAnswer(callId, sdp, generation)
        }
    }

    override fun onIceCandidate(
        callId: String,
        candidate: String,
        sdpMid: String?,
        sdpMLineIndex: Int?,
        usernameFragment: String?,
        messageId: String,
        generation: Int
    ) {
        coordinatorScope.launch(Dispatchers.Main) {
            webRtcSession.handleRemoteCandidate(callId, candidate, generation, sdpMid, sdpMLineIndex)
        }
    }

    override fun onConnectionStateChanged(connected: Boolean) {
        Log.i(TAG, "SignalR connection state changed: $connected")
    }

    private fun onSignalRReconnected() {
        Log.i(TAG, "SignalR reconnected, re-checking active call snapshot")
        val callId = activeCallId ?: return
        coordinatorScope.launch(Dispatchers.Main) {
            if (activeCallId == callId && !isTerminal(serverStatus)) startReconciliation(callId, currentOperationId)
        }
    }

    // NativeWebRtcSession.Listener
    override fun onLocalMediaConnected() {
        coordinatorScope.launch(Dispatchers.Main) {
            val callId = activeCallId ?: return@launch
            ringbackPlayer.stop()
            mediaState = DriverVoiceMediaState.CONNECTED
            updateNotification("Connecting...")
            incrementRevisionAndNotify()
            withContext(ioDispatcher) {
                apiClient.reportConnected(callId)
            }
        }
    }

    override fun onMediaDisconnected() {
        mediaState = DriverVoiceMediaState.DISCONNECTED
        incrementRevisionAndNotify()
    }

    override fun onMediaFailed() {
        val callId = activeCallId
        handleTerminal(DriverVoiceServerCallStatus.FAILED, DriverVoiceTerminationReason.NETWORK_FAILURE)
        callId?.let { coordinatorScope.launch(ioDispatcher) { apiClient.endCall(it) } }
    }

    private fun startReconciliation(callId: String, operationId: String) {
        reconciliationJob?.cancel()
        reconciliationJob = coordinatorScope.launch {
            while (isActive && activeCallId == callId && currentOperationId == operationId && !isTerminal(serverStatus)) {
                val snapshot = withContext(ioDispatcher) { apiClient.getCallSnapshot(callId) }
                if (activeCallId != callId || currentOperationId != operationId || isTerminal(serverStatus)) break
                if (snapshot != null && snapshot.callId == callId && snapshot.sequence >= serverSequence) {
                    serverSequence = snapshot.sequence
                    connectedAtUtc = snapshot.connectedAtUtc ?: connectedAtUtc
                    deadlineAtUtc = snapshot.deadlineAtUtc
                    updateStatusFromRest(snapshot.status)
                    incrementRevisionAndNotify()
                }
                if (isTerminal(serverStatus)) break
                delay(if (serverStatus == DriverVoiceServerCallStatus.ACTIVE) 10000 else 2000)
            }
        }
    }
}

