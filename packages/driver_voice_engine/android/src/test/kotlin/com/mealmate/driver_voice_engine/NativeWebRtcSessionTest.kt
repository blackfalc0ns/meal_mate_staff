package com.mealmate.driver_voice_engine

import android.content.Context
import org.mockito.ArgumentCaptor
import org.mockito.Mockito.*
import org.webrtc.*
import kotlin.test.*

class NativeWebRtcSessionTest {
    private val signaling = mock(VoiceSignalRClient::class.java)
    private val listener = mock(NativeWebRtcSession.Listener::class.java)
    private val factory = mock(PeerConnectionFactory::class.java)
    private val peer = mock(PeerConnection::class.java)
    private val track = mock(AudioTrack::class.java)
    private val source = mock(AudioSource::class.java)
    private val session = NativeWebRtcSession(mock(Context::class.java), signaling, { factory }, { it() })

    private fun start(): PeerConnection.Observer {
        `when`(factory.createPeerConnection(any(PeerConnection.RTCConfiguration::class.java), any(PeerConnection.Observer::class.java))).thenReturn(peer)
        `when`(factory.createAudioSource(any(MediaConstraints::class.java))).thenReturn(source)
        `when`(factory.createAudioTrack(anyString(), any(AudioSource::class.java))).thenReturn(track)
        `when`(peer.addTrack(any(MediaStreamTrack::class.java), anyList())).thenReturn(mock(RtpSender::class.java))
        session.listener = listener
        session.startOfferSession("call-1", 0, listOf(NativeIceServer(listOf("stun:example.test:3478"), null, null)))
        val observer = ArgumentCaptor.forClass(PeerConnection.Observer::class.java)
        verify(factory).createPeerConnection(any(PeerConnection.RTCConfiguration::class.java), observer.capture())
        return observer.value
    }

    @Test
    fun receivingAnAnswerAloneMustNotReportAudioConnected() {
        val observer = start()
        session.handleRemoteAnswer("call-1", "v=0\r\n", 0)
        verify(listener, never()).onLocalMediaConnected()
        observer.onConnectionChange(PeerConnection.PeerConnectionState.CONNECTED)
        observer.onConnectionChange(PeerConnection.PeerConnectionState.CONNECTED)
        verify(listener, times(1)).onLocalMediaConnected()
    }

    @Test
    fun sendsGeneratedOfferOnlyAfterSettingLocalDescription() {
        val observer = start()
        val create = ArgumentCaptor.forClass(SdpObserver::class.java)
        verify(peer).createOffer(create.capture(), any(MediaConstraints::class.java))
        val offer = SessionDescription(SessionDescription.Type.OFFER, "real-generated-sdp")
        create.value.onCreateSuccess(offer)
        verify(signaling, never()).sendOffer(anyString(), anyString(), anyString(), anyInt())
        val local = ArgumentCaptor.forClass(SdpObserver::class.java)
        verify(peer).setLocalDescription(local.capture(), eq(offer))
        local.value.onSetSuccess()
        val sent = mockingDetails(signaling).invocations.single { it.method.name == "sendOffer" }
        assertEquals("call-1", sent.arguments[0])
        assertEquals("real-generated-sdp", sent.arguments[1])
        assertEquals(0, sent.arguments[3])
        observer.onIceCandidate(IceCandidate("audio", 0, "candidate:local"))
        session.resendOffer()
        val resent = mockingDetails(signaling).invocations.filter { it.method.name == "sendOffer" }
        assertEquals(2, resent.size)
        assertEquals("real-generated-sdp", resent.last().arguments[1])
        val candidates = mockingDetails(signaling).invocations.filter { it.method.name == "sendIceCandidate" }
        assertEquals(2, candidates.size, "Rebinding must replay candidates gathered during an outage")
        assertEquals("candidate:local", candidates.last().arguments[1])
        verify(peer, times(1)).createOffer(any(SdpObserver::class.java), any(MediaConstraints::class.java))
    }

    @Test
    fun queuesIceUntilRemoteDescriptionAndPreservesMidAndLineIndex() {
        start()
        session.handleRemoteCandidate("another-call", "wrong", 0, "0", 0)
        session.handleRemoteCandidate("call-1", "future-generation", 1, "0", 0)
        session.handleRemoteCandidate("call-1", "candidate:real", 0, "audio", 2)
        verify(peer, never()).addIceCandidate(any(IceCandidate::class.java))
        session.handleRemoteAnswer("call-1", "answer", 0)
        val remote = ArgumentCaptor.forClass(SdpObserver::class.java)
        verify(peer).setRemoteDescription(remote.capture(), any(SessionDescription::class.java))
        remote.value.onSetSuccess()
        val ice = ArgumentCaptor.forClass(IceCandidate::class.java)
        verify(peer, times(1)).addIceCandidate(ice.capture())
        assertEquals("candidate:real", ice.value.sdp)
        assertEquals("audio", ice.value.sdpMid)
        assertEquals(2, ice.value.sdpMLineIndex)
    }

    @Test
    fun muteControlsRealAudioTrackAndStopDisposesItAndRejectsLateCallbacks() {
        val observer = start()
        session.setMuted(true)
        verify(track).setEnabled(false)
        session.stop()
        verify(peer).close()
        verify(peer).dispose()
        verify(track).dispose()
        verify(source).dispose()
        verify(factory).dispose()
        observer.onConnectionChange(PeerConnection.PeerConnectionState.CONNECTED)
        verify(listener, never()).onLocalMediaConnected()
    }

    @Test
    fun missingIceFailsInsteadOfPretendingToConnect() {
        session.listener = listener
        session.startOfferSession("call-1", 0, emptyList())
        verify(listener).onMediaFailed()
        verifyNoInteractions(factory)
    }
}
