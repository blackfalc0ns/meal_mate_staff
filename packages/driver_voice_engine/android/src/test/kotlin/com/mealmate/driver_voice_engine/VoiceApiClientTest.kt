package com.mealmate.driver_voice_engine

import kotlinx.coroutines.runBlocking
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import okhttp3.mockwebserver.SocketPolicy
import org.mockito.Mockito.*
import kotlin.test.*

class VoiceApiClientTest {
    private fun withClient(block: suspend (VoiceApiClient, MockWebServer, MutableList<String?>) -> Unit) = runBlocking {
        val server = MockWebServer()
        server.start()
        try {
            val store = mock(VoiceCallStore::class.java)
            var token = "old"
            `when`(store.getBaseUrl()).thenReturn(server.url("").toString().trimEnd('/'))
            `when`(store.getAccessToken()).thenAnswer { token }
            `when`(store.getDeviceSessionId()).thenReturn("owned-session")
            `when`(store.getControlProof()).thenReturn("owned-proof")
            val client = VoiceApiClient(store)
            val forced = mutableListOf<String?>()
            client.tokenProvider = { rejected, force ->
                if (force) { forced.add(rejected); token = "new" }
                token
            }
            block(client, server, forced)
            verify(store, never()).setRefreshToken(anyString())
        } finally { server.shutdown() }
    }

    @Test fun refresh409KeepsTheSameInitiationKeyAndVoiceSession() = withClient { client, server, refreshes ->
        server.enqueue(MockResponse().setResponseCode(409).setBody("""{"code":"calls.auth_refresh_required"}"""))
        server.enqueue(MockResponse().setBody("""{"callId":"call-1","tripStopId":"stop","status":"Ringing"}"""))
        assertEquals("call-1", client.initiateCall("stop", "same-key")?.callId)
        val first = server.takeRequest()
        val retry = server.takeRequest()
        assertEquals(first.body.readUtf8(), retry.body.readUtf8())
        assertEquals("owned-session", retry.getHeader("X-Voice-Device-Session"))
        assertEquals("owned-proof", retry.getHeader("X-Voice-Device-Proof"))
        assertEquals("Bearer new", retry.getHeader("Authorization"))
        assertEquals(listOf<String?>("old"), refreshes.toList())
        assertEquals(2, server.requestCount)
    }

    @Test fun heartbeat401RefreshesOnceWithoutRotatingIndependently() = withClient { client, server, refreshes ->
        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(200))
        assertTrue(client.sendHeartbeat("call-1"))
        assertEquals(listOf<String?>("old"), refreshes.toList())
        assertEquals(2, server.requestCount)
    }

    @Test fun repeated401StopsAfterOneRetry() = withClient { client, server, refreshes ->
        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(401))
        assertFalse(client.sendHeartbeat("call-1"))
        assertEquals(1, refreshes.size)
        assertEquals(2, server.requestCount)
    }

    @Test fun lostInitiationResponseReplaysTheSameOperation() = withClient { client, server, _ ->
        server.enqueue(MockResponse().setSocketPolicy(SocketPolicy.DISCONNECT_AFTER_REQUEST))
        server.enqueue(MockResponse().setBody("""{"callId":"original-call","tripStopId":"stop","status":"Ringing"}"""))
        assertEquals("original-call", client.initiateCall("stop", "same-key")?.callId)
        assertEquals(server.takeRequest().body.readUtf8(), server.takeRequest().body.readUtf8())
        assertEquals(2, server.requestCount)
    }
}
