package com.mealmate.driver_voice_engine

import org.mockito.Mockito.*
import kotlin.test.*

class VoiceSessionManagerTest {

    private lateinit var mockStore: VoiceCallStore
    private lateinit var mockApiClient: VoiceApiClient

    @BeforeTest
    fun setUp() {
        mockStore = mock(VoiceCallStore::class.java)
        mockApiClient = mock(VoiceApiClient::class.java)
    }

    @Test
    fun testIsSessionValidReturnsFalseWhenMissingSessionIdOrProof() {
        val manager = VoiceSessionManager(mockStore, mockApiClient)

        `when`(mockStore.getDeviceSessionId()).thenReturn(null)
        `when`(mockStore.getControlProof()).thenReturn("proof")
        `when`(mockStore.getExpiresAtUtc()).thenReturn("2026-10-22T23:59:59Z")
        assertFalse(manager.isSessionValid())

        `when`(mockStore.getDeviceSessionId()).thenReturn("session-1")
        `when`(mockStore.getControlProof()).thenReturn(null)
        assertFalse(manager.isSessionValid())
    }

    @Test
    fun testIsSessionValidReturnsFalseWhenExpired() {
        val manager = VoiceSessionManager(mockStore, mockApiClient)
        `when`(mockStore.getDeviceSessionId()).thenReturn("session-1")
        `when`(mockStore.getControlProof()).thenReturn("proof-1")
        // Expired timestamp
        `when`(mockStore.getExpiresAtUtc()).thenReturn("2020-01-01T00:00:00Z")

        assertFalse(manager.isSessionValid())
    }

    @Test
    fun testIsSessionValidReturnsTrueWhenFarInFuture() {
        val manager = VoiceSessionManager(mockStore, mockApiClient)
        `when`(mockStore.getDeviceSessionId()).thenReturn("session-1")
        `when`(mockStore.getControlProof()).thenReturn("proof-1")
        // Year 2099
        `when`(mockStore.getExpiresAtUtc()).thenReturn("2099-01-01T00:00:00Z")

        assertTrue(manager.isSessionValid())
    }

    @Test
    fun testGetVoiceHeadersGeneratesExpectedHeaders() {
        val manager = VoiceSessionManager(mockStore, mockApiClient)
        `when`(mockStore.getAccessToken()).thenReturn("jwt-secret")
        `when`(mockStore.getDeviceSessionId()).thenReturn("session-123")
        `when`(mockStore.getControlProof()).thenReturn("proof-abc")

        val headers = manager.getVoiceHeaders()
        assertEquals("Bearer jwt-secret", headers["Authorization"])
        assertEquals("session-123", headers["X-Voice-Device-Session"])
        assertEquals("proof-abc", headers["X-Voice-Device-Proof"])
    }
}
