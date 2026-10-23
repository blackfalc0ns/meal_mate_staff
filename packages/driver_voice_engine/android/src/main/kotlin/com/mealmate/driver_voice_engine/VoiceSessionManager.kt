package com.mealmate.driver_voice_engine

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class VoiceSessionManager(
    private val store: VoiceCallStore,
    private val apiClient: VoiceApiClient
) {
    private val lock = Any()
    private var registrationInProgress = false

    fun isSessionValid(): Boolean {
        val sessionId = store.getDeviceSessionId()
        if (sessionId.isNullOrBlank()) return false
        val proof = store.getControlProof()
        if (proof.isNullOrBlank()) return false
        val expiresAt = store.getExpiresAtUtc() ?: return false

        return try {
            val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US).apply {
                timeZone = TimeZone.getTimeZone("UTC")
            }
            val cleanDateStr = if (expiresAt.contains(".")) {
                expiresAt.substringBefore(".")
            } else if (expiresAt.endsWith("Z")) {
                expiresAt.substringBefore("Z")
            } else {
                expiresAt
            }
            val expiryDate = format.parse(cleanDateStr) ?: return false
            // 60-second safety margin
            val nowMs = System.currentTimeMillis()
            expiryDate.time - 60000 > nowMs
        } catch (_: Exception) {
            false
        }
    }

    suspend fun ensureSession(): Boolean {
        synchronized(lock) {
            if (isSessionValid()) return true
        }

        val fcmDeviceTokenId = store.getFcmDeviceTokenId()
        if (fcmDeviceTokenId.isNullOrBlank()) {
            return false
        }

        val installationId = store.getInstallationId()
        val response = apiClient.registerDevice(
            fcmDeviceTokenId = fcmDeviceTokenId,
            installationId = installationId,
            platform = "android",
            capabilityVersion = 2
        )

        return if (response != null && response.deviceSessionId.isNotBlank()) {
            store.saveDeviceSession(
                sessionId = response.deviceSessionId,
                proof = response.controlProof,
                expiresAtUtc = response.expiresAtUtc
            )
            true
        } else {
            false
        }
    }

    fun getVoiceHeaders(): Map<String, String> {
        val headers = mutableMapOf<String, String>()
        val token = store.getAccessToken()
        if (!token.isNullOrBlank()) {
            headers["Authorization"] = "Bearer $token"
        }
        val sessionId = store.getDeviceSessionId()
        if (!sessionId.isNullOrBlank()) {
            headers["X-Voice-Device-Session"] = sessionId
        }
        val proof = store.getControlProof()
        if (!proof.isNullOrBlank()) {
            headers["X-Voice-Device-Proof"] = proof
        }
        return headers
    }
}
