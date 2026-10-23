package com.mealmate.driver_voice_engine

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import org.webrtc.*
import org.webrtc.audio.JavaAudioDeviceModule
import java.util.UUID

/** Owns the actual microphone, RTP transport and remote audio playback. */
class NativeWebRtcSession(
    private val context: Context,
    private val signalRClient: VoiceSignalRClient,
    private val factoryProvider: (() -> PeerConnectionFactory)? = null,
    private val dispatch: ((() -> Unit) -> Unit) = { action -> Handler(Looper.getMainLooper()).post(action) }
) {
    companion object { private const val TAG = "NativeWebRtcSession" }
    interface Listener {
        fun onLocalMediaConnected()
        fun onMediaDisconnected()
        fun onMediaFailed()
    }
    var listener: Listener? = null
    private var activeCallId: String? = null
    private var activeGeneration = 0
    private var epoch = 0
    private var factory: PeerConnectionFactory? = null
    private var peer: PeerConnection? = null
    private var audioSource: AudioSource? = null
    private var localAudio: AudioTrack? = null
    private var remoteDescriptionSet = false
    private var answerPending = false
    private var connected = false
    private var muted = false
    private var localOffer: String? = null
    private val queuedCandidates = mutableListOf<IceCandidate>()
    private val localCandidates = mutableListOf<IceCandidate>()

    fun startOfferSession(callId: String, generation: Int, iceServers: List<NativeIceServer>) {
        stop()
        activeCallId = callId
        activeGeneration = generation
        val sessionEpoch = epoch
        if (iceServers.isEmpty()) { fail("No ICE servers supplied"); return }
        try {
            val rtcFactory = factoryProvider?.invoke() ?: createFactory()
            factory = rtcFactory
            val config = PeerConnection.RTCConfiguration(iceServers.map {
                PeerConnection.IceServer.builder(it.urls)
                    .setUsername(it.username.orEmpty()).setPassword(it.credential.orEmpty()).createIceServer()
            }).apply {
                sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN
                bundlePolicy = PeerConnection.BundlePolicy.MAXBUNDLE
                rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.REQUIRE
            }
            val observer = object : PeerConnection.Observer {
                override fun onSignalingChange(state: PeerConnection.SignalingState) {}
                override fun onIceConnectionChange(state: PeerConnection.IceConnectionState) {}
                override fun onIceConnectionReceivingChange(receiving: Boolean) {}
                override fun onIceGatheringChange(state: PeerConnection.IceGatheringState) {}
                override fun onIceCandidatesRemoved(candidates: Array<out IceCandidate>) {}
                override fun onAddStream(stream: MediaStream) {}
                override fun onRemoveStream(stream: MediaStream) {}
                override fun onDataChannel(channel: DataChannel) {}
                override fun onRenegotiationNeeded() {}
                override fun onAddTrack(receiver: RtpReceiver, streams: Array<out MediaStream>) {}
                override fun onTrack(transceiver: RtpTransceiver) {
                    dispatch {
                        if (epoch == sessionEpoch) (transceiver.receiver.track() as? AudioTrack)?.setEnabled(true)
                    }
                }
                override fun onIceCandidate(candidate: IceCandidate) {
                    dispatch {
                        if (epoch == sessionEpoch) {
                            localCandidates.add(candidate)
                            sendCandidate(callId, candidate)
                        }
                    }
                }
                override fun onConnectionChange(state: PeerConnection.PeerConnectionState) {
                    dispatch {
                        if (epoch != sessionEpoch) return@dispatch
                        when (state) {
                            PeerConnection.PeerConnectionState.CONNECTED -> if (!connected) {
                                connected = true
                                Log.i(TAG, "Native audio transport connected")
                                listener?.onLocalMediaConnected()
                            }
                            PeerConnection.PeerConnectionState.DISCONNECTED -> {
                                connected = false
                                listener?.onMediaDisconnected()
                            }
                            PeerConnection.PeerConnectionState.FAILED -> fail("ICE/DTLS connection failed")
                            else -> Unit
                        }
                    }
                }
            }
            val connection = rtcFactory.createPeerConnection(config, observer)
                ?: error("Unable to create audio peer connection")
            peer = connection
            audioSource = rtcFactory.createAudioSource(MediaConstraints().apply {
                mandatory.add(MediaConstraints.KeyValuePair("googEchoCancellation", "true"))
                mandatory.add(MediaConstraints.KeyValuePair("googNoiseSuppression", "true"))
                mandatory.add(MediaConstraints.KeyValuePair("googAutoGainControl", "true"))
            })
            localAudio = rtcFactory.createAudioTrack("driver-audio", audioSource).apply { setEnabled(!muted) }
            check(connection.addTrack(localAudio, listOf("driver-stream")) != null) { "Unable to add microphone track" }
            connection.createOffer(object : SimpleSdpObserver() {
                override fun onCreateSuccess(sdp: SessionDescription) {
                    dispatch {
                        if (epoch != sessionEpoch) return@dispatch
                        connection.setLocalDescription(object : SimpleSdpObserver() {
                            override fun onSetSuccess() {
                                dispatch {
                                    if (epoch == sessionEpoch) {
                                        localOffer = sdp.description
                                        resendOffer()
                                    }
                                }
                            }
                            override fun onSetFailure(error: String) { failIfCurrent(sessionEpoch, error) }
                        }, sdp)
                    }
                }
                override fun onCreateFailure(error: String) { failIfCurrent(sessionEpoch, error) }
            }, MediaConstraints())
        } catch (error: Exception) { fail(error.message ?: "Cannot initialize native audio") }
    }

    private fun createFactory(): PeerConnectionFactory {
        PeerConnectionFactory.initialize(PeerConnectionFactory.InitializationOptions.builder(context).createInitializationOptions())
        val audioModule = JavaAudioDeviceModule.builder(context).createAudioDeviceModule()
        return try {
            PeerConnectionFactory.builder().setAudioDeviceModule(audioModule).createPeerConnectionFactory()
        } finally { audioModule.release() }
    }

    fun handleRemoteAnswer(callId: String, sdp: String, generation: Int) {
        if (callId != activeCallId || generation != activeGeneration || remoteDescriptionSet || answerPending) return
        val connection = peer ?: return
        val sessionEpoch = epoch
        answerPending = true
        connection.setRemoteDescription(object : SimpleSdpObserver() {
            override fun onSetSuccess() {
                dispatch {
                    if (epoch != sessionEpoch) return@dispatch
                    remoteDescriptionSet = true
                    answerPending = false
                    queuedCandidates.forEach { connection.addIceCandidate(it) }
                    queuedCandidates.clear()
                }
            }
            override fun onSetFailure(error: String) { failIfCurrent(sessionEpoch, error) }
        }, SessionDescription(SessionDescription.Type.ANSWER, sdp))
    }

    fun handleRemoteCandidate(
        callId: String, candidate: String, generation: Int,
        sdpMid: String? = null, sdpMLineIndex: Int? = null
    ) {
        if (callId != activeCallId || generation != activeGeneration || candidate.isBlank()) return
        val ice = IceCandidate(sdpMid, sdpMLineIndex ?: 0, candidate)
        if (remoteDescriptionSet) peer?.addIceCandidate(ice) else queuedCandidates.add(ice)
    }

    fun setMuted(value: Boolean) { muted = value; localAudio?.setEnabled(!value) }

    /** Resend the same SDP after rebinding; do not replace the live peer connection. */
    fun resendOffer() {
        val callId = activeCallId ?: return
        val sdp = localOffer ?: return
        if (!remoteDescriptionSet && !answerPending && !signalRClient.sendOffer(callId, sdp, UUID.randomUUID().toString(), activeGeneration)) {
            Log.w(TAG, "Offer delivery deferred until signaling is rebound")
        }
        localCandidates.forEach { sendCandidate(callId, it) }
    }

    private fun sendCandidate(callId: String, candidate: IceCandidate) {
        signalRClient.sendIceCandidate(
            callId, candidate.sdp, candidate.sdpMid, candidate.sdpMLineIndex,
            null, UUID.randomUUID().toString(), activeGeneration
        )
    }

    private fun failIfCurrent(sessionEpoch: Int, error: String) {
        dispatch { if (epoch == sessionEpoch) fail(error) }
    }
    private fun fail(error: String) {
        Log.e(TAG, error)
        stop()
        listener?.onMediaFailed()
    }

    fun stop() {
        epoch++
        activeCallId = null
        connected = false
        remoteDescriptionSet = false
        answerPending = false
        localOffer = null
        queuedCandidates.clear()
        localCandidates.clear()
        val oldPeer = peer
        peer = null
        oldPeer?.close()
        oldPeer?.dispose()
        localAudio?.dispose()
        localAudio = null
        audioSource?.dispose()
        audioSource = null
        factory?.dispose()
        factory = null
    }

    private open class SimpleSdpObserver : SdpObserver {
        override fun onCreateSuccess(sdp: SessionDescription) {}
        override fun onSetSuccess() {}
        override fun onCreateFailure(error: String) {}
        override fun onSetFailure(error: String) {}
    }
}
