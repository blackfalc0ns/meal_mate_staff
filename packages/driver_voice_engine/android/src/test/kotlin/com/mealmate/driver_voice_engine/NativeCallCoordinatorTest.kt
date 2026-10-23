package com.mealmate.driver_voice_engine

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.json.JSONObject
import org.mockito.Mockito.*
import kotlin.test.*

@OptIn(ExperimentalCoroutinesApi::class)
class NativeCallCoordinatorTest {
    private fun withCoordinator(
        dispatcher: CoroutineDispatcher = Dispatchers.IO,
        block: (NativeCallCoordinator, RingbackPlayer, NativeWebRtcSession, VoiceApiClient) -> Unit
    ) {
        val store = mockConstruction(VoiceCallStore::class.java)
        val api = mockConstruction(VoiceApiClient::class.java)
        val session = mockConstruction(VoiceSessionManager::class.java)
        val signal = mockConstruction(VoiceSignalRClient::class.java)
        val ring = mockConstruction(RingbackPlayer::class.java)
        val proximity = mockConstruction(ProximityController::class.java)
        val telecom = mockConstruction(TelecomCallAdapter::class.java)
        val rtc = mockConstruction(NativeWebRtcSession::class.java)
        try {
            val context = mock(Context::class.java)
            `when`(context.getSystemService(Context.NOTIFICATION_SERVICE)).thenReturn(mock(android.app.NotificationManager::class.java))
            val coordinator = NativeCallCoordinator(context, dispatcher)
            fun seed(name: String, value: Any) {
                NativeCallCoordinator::class.java.getDeclaredField(name).apply { isAccessible = true }.set(coordinator, value)
            }
            seed("activeCallId", "call-1")
            seed("serverSequence", 1)
            seed("serverStatus", DriverVoiceServerCallStatus.RINGING)
            kotlinx.coroutines.runBlocking {
                `when`(signal.constructed().single().connectAndAwaitBound()).thenReturn(true)
                `when`(api.constructed().single().getIceServers("call-1"))
                    .thenReturn(listOf(NativeIceServer(listOf("stun:example.test:3478"), null, null)))
            }
            block(coordinator, ring.constructed().single(), rtc.constructed().single(), api.constructed().single())
        } finally {
            listOf(rtc, telecom, proximity, ring, signal, session, api, store).forEach { it.close() }
        }
    }
    private fun event(callId: String, status: String, sequence: Int) = JSONObject()
        .put("callId", callId).put("sequence", sequence)
        .put("payload", JSONObject().put("status", status))

    @Test
    fun definitiveAuthFailureStopsLocalMediaWithoutWaitingForServer() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        Dispatchers.setMain(dispatcher)
        try {
            withCoordinator(dispatcher) { coordinator, ring, rtc, api ->
                coordinator.terminateLocalSession()
                assertEquals(DriverVoiceServerCallStatus.FAILED, coordinator.getCurrentSnapshot().serverStatus)
                verify(ring).stop()
                verify(rtc).stop()
                verify(coordinator.telecomAdapter).cancelNotification()
                verify(coordinator.store).clearAll()
                assertEquals(0, mockingDetails(api).invocations.size)
            }
        } finally { Dispatchers.resetMain() }
    }

    @Test
    fun acceptedStopsRingingAndRepeatedConnectingDoesNotRestartAudio() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        Dispatchers.setMain(dispatcher)
        try {
            withCoordinator(dispatcher) { coordinator, ring, rtc, _ ->
                coordinator.onCallEvent(event("call-1", "Accepted", 2))
                runCurrent()
                assertEquals(DriverVoiceServerCallStatus.ACCEPTED, coordinator.getCurrentSnapshot().serverStatus)
                verify(ring).stop()
                coordinator.onCallEvent(event("call-1", "Connecting", 3))
                runCurrent()
                assertEquals(1, mockingDetails(rtc).invocations.count { it.method.name == "startOfferSession" })
                coordinator.onCallEvent(event("call-1", "Ended", 4))
                runCurrent()
            }
        } finally { Dispatchers.resetMain() }
    }

    @Test
    fun missedAcceptedAndEndedEventsAreRecoveredFromSnapshots() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        Dispatchers.setMain(dispatcher)
        try {
            withCoordinator(dispatcher) { coordinator, ring, rtc, api ->
                fun snapshot(status: String, seq: Int) = NativeCallSnapshotResponse(
                    "call-1", "stop-1", status, seq, null, null, null, null, null, null, null
                )
                kotlinx.coroutines.runBlocking {
                    `when`(api.getCallSnapshot("call-1")).thenReturn(snapshot("Accepted", 2), snapshot("Ended", 3))
                }
                coordinator.onBound()
                runCurrent()
                assertEquals(DriverVoiceServerCallStatus.ACCEPTED, coordinator.getCurrentSnapshot().serverStatus)
                verify(ring).stop()
                assertEquals(1, mockingDetails(rtc).invocations.count { it.method.name == "startOfferSession" })
                advanceTimeBy(2000)
                runCurrent()
                assertEquals(DriverVoiceServerCallStatus.ENDED, coordinator.getCurrentSnapshot().serverStatus)
                verify(rtc).stop()
            }
        } finally { Dispatchers.resetMain() }
    }

    @Test
    fun remoteTerminationStopsRingingAndClosesAudio() = runTest {
        Dispatchers.setMain(StandardTestDispatcher(testScheduler))
        try {
            withCoordinator { coordinator, ring, rtc, _ ->
                coordinator.onCallEvent(event("call-1", "Ended", 2))
                runCurrent()
                assertEquals(DriverVoiceServerCallStatus.ENDED, coordinator.getCurrentSnapshot().serverStatus)
                verify(ring).stop()
                verify(rtc).stop()
                coordinator.onCallEvent(event("call-1", "Ringing", 3))
                runCurrent()
                assertEquals(DriverVoiceServerCallStatus.ENDED, coordinator.getCurrentSnapshot().serverStatus)
                verify(ring, never()).start()
            }
        } finally { Dispatchers.resetMain() }
    }

    @Test
    fun unrelatedOrOldEventsCannotChangeTheCurrentCall() = runTest {
        Dispatchers.setMain(StandardTestDispatcher(testScheduler))
        try {
            withCoordinator { coordinator, ring, _, _ ->
                coordinator.onCallEvent(event("foreign-call", "Ended", 99))
                coordinator.onCallEvent(event("call-1", "Ended", 1))
                runCurrent()
                assertEquals(DriverVoiceServerCallStatus.RINGING, coordinator.getCurrentSnapshot().serverStatus)
                assertEquals(1L, coordinator.getCurrentSnapshot().serverSequence)
                verifyNoInteractions(ring)
            }
        } finally { Dispatchers.resetMain() }
    }

    @Test
    fun repeatedActiveUpdatesDoNotPostponeHeartbeats() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        Dispatchers.setMain(dispatcher)
        try {
            withCoordinator(dispatcher) { coordinator, _, _, api ->
                NativeCallCoordinator::class.java.getDeclaredField("offerStarted").apply { isAccessible = true }.set(coordinator, true)
                coordinator.onCallEvent(event("call-1", "Active", 2))
                runCurrent()
                advanceTimeBy(10000)
                coordinator.onCallEvent(event("call-1", "Active", 3))
                runCurrent()
                advanceTimeBy(10000)
                coordinator.onCallEvent(event("call-1", "Active", 4))
                runCurrent()
                advanceTimeBy(10001)
                runCurrent()
                assertEquals(2, mockingDetails(api).invocations.count { it.method.name == "sendHeartbeat" })
                coordinator.onCallEvent(event("call-1", "Ended", 5))
                runCurrent()
            }
        } finally { Dispatchers.resetMain() }
    }
}
