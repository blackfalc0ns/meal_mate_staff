package com.mealmate.driver_voice_engine

import android.content.Context
import android.content.SharedPreferences
import org.mockito.Mockito.*
import kotlin.test.*

class VoiceCallStoreTest {

    private lateinit var mockContext: Context
    private lateinit var mockPrefs: SharedPreferences
    private lateinit var mockEditor: SharedPreferences.Editor
    private val memoryStore = mutableMapOf<String, Any?>()

    @BeforeTest
    fun setUp() {
        mockContext = mock(Context::class.java)
        mockPrefs = mock(SharedPreferences::class.java)
        mockEditor = mock(SharedPreferences.Editor::class.java)

        `when`(mockContext.getSharedPreferences(anyString(), anyInt())).thenReturn(mockPrefs)
        `when`(mockPrefs.edit()).thenReturn(mockEditor)
        `when`(mockEditor.putString(anyString(), anyString())).thenAnswer { inv ->
            memoryStore[inv.arguments[0] as String] = inv.arguments[1]
            mockEditor
        }
        `when`(mockEditor.putBoolean(anyString(), anyBoolean())).thenAnswer { inv ->
            memoryStore[inv.arguments[0] as String] = inv.arguments[1]
            mockEditor
        }
        `when`(mockEditor.remove(anyString())).thenAnswer { inv ->
            memoryStore.remove(inv.arguments[0] as String)
            mockEditor
        }
        `when`(mockEditor.clear()).thenAnswer {
            memoryStore.clear()
            mockEditor
        }
        doNothing().`when`(mockEditor).apply()

        `when`(mockPrefs.getString(anyString(), any())).thenAnswer { inv ->
            val key = inv.arguments[0] as String
            val def = inv.arguments[1] as? String
            memoryStore[key] as? String ?: def
        }
        `when`(mockPrefs.getBoolean(anyString(), anyBoolean())).thenAnswer { inv ->
            val key = inv.arguments[0] as String
            val def = inv.arguments[1] as Boolean
            memoryStore[key] as? Boolean ?: def
        }
    }

    @Test
    fun tokenPairRotationPreservesOwnedVoiceSessionAndProof() {
        `when`(mockEditor.commit()).thenReturn(true)
        val store = VoiceCallStore(mockContext)
        store.saveDeviceSession("same-session", "same-proof", "2030-01-01T00:00:00Z")
        store.saveTokenPair("new-access", "new-refresh")
        assertEquals("new-access", store.getAccessToken())
        assertEquals("new-refresh", store.getRefreshToken())
        assertEquals("same-session", store.getDeviceSessionId())
        assertEquals("same-proof", store.getControlProof())
        verify(mockEditor).commit()
    }

    @Test
    fun testSaveAndRetrieveAccountSession() {
        val store = VoiceCallStore(mockContext)
        val session = DriverVoiceAccountSession(
            accessToken = "jwt-abc-123",
            refreshToken = "refresh-xyz",
            userId = "usr-1",
            baseUrl = "https://maelmate.runasp.net",
            hubUrl = "https://maelmate.runasp.net/hubs/voice-call-v2",
            installationId = "inst-007",
            fcmDeviceTokenId = "fcm-guid-111",
            apnsVoipToken = null,
            platform = "android"
        )

        store.saveAccountSession(session)

        assertEquals("jwt-abc-123", store.getAccessToken())
        assertEquals("refresh-xyz", store.getRefreshToken())
        assertEquals("https://maelmate.runasp.net", store.getBaseUrl())
        assertEquals("inst-007", store.getInstallationId())
        assertEquals("fcm-guid-111", store.getFcmDeviceTokenId())
    }

    @Test
    fun testSaveAndClearDeviceSession() {
        val store = VoiceCallStore(mockContext)
        store.saveDeviceSession("sess-1", "proof-999", "2026-10-22T21:00:00Z")

        assertEquals("sess-1", store.getDeviceSessionId())
        assertEquals("proof-999", store.getControlProof())
        assertEquals("2026-10-22T21:00:00Z", store.getExpiresAtUtc())

        store.clearDeviceSession()
        assertNull(store.getDeviceSessionId())
        assertNull(store.getControlProof())
        assertNull(store.getExpiresAtUtc())
    }

    @Test
    fun testCallReconciliationMetadata() {
        val store = VoiceCallStore(mockContext)
        store.saveCallReconciliation(
            callId = "call-1",
            tripStopId = "stop-1",
            clientRequestId = "req-1",
            endPending = true
        )

        assertEquals("call-1", store.getLastCallId())
        assertTrue(store.isServerEndPending())

        store.setServerEndPending(false)
        assertFalse(store.isServerEndPending())

        store.clearCallReconciliation()
        assertNull(store.getLastCallId())
    }

    @Test
    fun testClearAllWipesEverything() {
        val store = VoiceCallStore(mockContext)
        store.saveDeviceSession("sess-1", "proof-999", "2026-10-22T21:00:00Z")
        store.clearAll()

        assertNull(store.getAccessToken())
        assertNull(store.getDeviceSessionId())
    }
}
