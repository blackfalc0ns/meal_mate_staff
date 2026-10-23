package com.mealmate.driver_voice_engine

import kotlinx.coroutines.*
import okhttp3.*
import okhttp3.mockwebserver.*
import org.mockito.Mockito.*
import kotlin.test.*

class VoiceSignalRClientTest {
    @Test
    fun unexpectedCleanClosureReconnectsAndBindsAgain() = runBlocking {
        val server = MockWebServer()
        val socket = CompletableDeferred<WebSocket>()
        val rebound = CompletableDeferred<Unit>()
        val count = java.util.concurrent.atomic.AtomicInteger()
        repeat(2) {
            server.enqueue(MockResponse().setBody("{\"connectionToken\":\"token\"}"))
            server.enqueue(MockResponse().withWebSocketUpgrade(object : WebSocketListener() {
                override fun onOpen(webSocket: WebSocket, response: Response) { socket.complete(webSocket) }
                override fun onClosing(webSocket: WebSocket, code: Int, reason: String) { webSocket.close(code, reason) }
                override fun onMessage(webSocket: WebSocket, text: String) {
                    if (text.contains("protocol")) webSocket.send("{}\u001e")
                    if (text.contains("BindDeviceSession")) webSocket.send("{\"type\":1,\"target\":\"bound\",\"arguments\":[]}\u001e")
                }
            }))
        }
        server.start()
        val store = mock(VoiceCallStore::class.java)
        `when`(store.getAccessToken()).thenReturn("test-jwt")
        `when`(store.getHubUrl()).thenReturn(server.url("/voice").toString())
        `when`(store.getDeviceSessionId()).thenReturn("device")
        `when`(store.getControlProof()).thenReturn("proof")
        val listener = mock(VoiceSignalRClient.Listener::class.java)
        doAnswer { if (count.incrementAndGet() == 2) rebound.complete(Unit); null }.`when`(listener).onBound()
        val client = VoiceSignalRClient(store).apply { this.listener = listener }
        try {
            assertTrue(client.connectAndAwaitBound(5000))
            socket.await().close(1001, "Server restart")
            withTimeout(10000) { rebound.await() }
            assertTrue(client.isBound())
            assertEquals(4, server.requestCount)
        } finally { client.disconnect(); server.shutdown() }
    }

    @Test
    fun waitsForDeviceBindingRatherThanOnlyWebsocketConnection() = runBlocking {
        val server = MockWebServer()
        val bound = CompletableDeferred<Unit>()
        val bindingReceived = CompletableDeferred<Unit>()
        val serverScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
        server.enqueue(MockResponse().setBody("{\"connectionToken\":\"token\"}"))
        server.enqueue(MockResponse().withWebSocketUpgrade(object : WebSocketListener() {
            override fun onClosing(webSocket: WebSocket, code: Int, reason: String) { webSocket.close(code, reason) }
            override fun onMessage(webSocket: WebSocket, text: String) {
                if (text.contains("protocol")) webSocket.send("{}\u001e")
                if (text.contains("BindDeviceSession")) {
                    bindingReceived.complete(Unit)
                    serverScope.launch {
                        bound.await()
                        webSocket.send("{\"type\":1,\"target\":\"bound\",\"arguments\":[]}\u001e")
                    }
                }
            }
        }))
        server.start()
        val store = mock(VoiceCallStore::class.java)
        `when`(store.getAccessToken()).thenReturn("test-jwt")
        `when`(store.getHubUrl()).thenReturn(server.url("/voice").toString())
        `when`(store.getDeviceSessionId()).thenReturn("device")
        `when`(store.getControlProof()).thenReturn("proof")
        val client = VoiceSignalRClient(store)
        try {
            val ready = async { client.connectAndAwaitBound(5000) }
            withTimeout(5000) { bindingReceived.await() }
            assertFalse(ready.isCompleted, "Call initiation must wait for the bound confirmation")
            bound.complete(Unit)
            assertTrue(withTimeout(5000) { ready.await() })
            assertTrue(client.isBound())
            `when`(store.getDeviceSessionId()).thenReturn("renewed-device")
            assertTrue(client.connectAndAwaitBound(1000), "A renewed session must rebind on the existing socket")
            assertEquals(2, server.requestCount, "Rebinding must not create another WebSocket")
        } finally {
            client.disconnect()
            serverScope.cancel()
            server.shutdown()
        }
    }

    @Test
    fun failedBindingTimesOutInsteadOfStartingACall() = runBlocking {
        val store = mock(VoiceCallStore::class.java)
        val client = VoiceSignalRClient(store)
        try { assertFalse(client.connectAndAwaitBound(100)) }
        finally { client.disconnect() }
    }
}
