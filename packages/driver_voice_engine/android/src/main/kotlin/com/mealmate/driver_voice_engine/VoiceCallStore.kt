package com.mealmate.driver_voice_engine

import android.content.Context
import android.content.SharedPreferences

class VoiceCallStore(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    companion object {
        private const val PREFS_NAME = "mealmate_voice_call_store"
        private const val KEY_ACCESS_TOKEN = "access_token"
        private const val KEY_REFRESH_TOKEN = "refresh_token"
        private const val KEY_USER_ID = "user_id"
        private const val KEY_BASE_URL = "base_url"
        private const val KEY_HUB_URL = "hub_url"
        private const val KEY_INSTALLATION_ID = "installation_id"
        private const val KEY_FCM_DEVICE_TOKEN_ID = "fcm_device_token_id"
        private const val KEY_APNS_VOIP_TOKEN = "apns_voip_token"
        private const val KEY_DEVICE_SESSION_ID = "device_session_id"
        private const val KEY_CONTROL_PROOF = "control_proof"
        private const val KEY_EXPIRES_AT_UTC = "expires_at_utc"
        private const val KEY_LAST_CALL_ID = "last_call_id"
        private const val KEY_LAST_TRIP_STOP_ID = "last_trip_stop_id"
        private const val KEY_LAST_CLIENT_REQUEST_ID = "last_client_request_id"
        private const val KEY_SERVER_END_PENDING = "server_end_pending"
    }

    @Synchronized
    fun saveAccountSession(session: DriverVoiceAccountSession) {
        val editor = prefs.edit()
            .putString(KEY_ACCESS_TOKEN, session.accessToken)
            .putString(KEY_USER_ID, session.userId)
            .putString(KEY_BASE_URL, session.baseUrl)
            .putString(KEY_HUB_URL, session.hubUrl)
            .putString(KEY_INSTALLATION_ID, session.installationId)

        if (session.refreshToken != null) {
            editor.putString(KEY_REFRESH_TOKEN, session.refreshToken)
        } else {
            editor.remove(KEY_REFRESH_TOKEN)
        }

        if (session.fcmDeviceTokenId != null) {
            editor.putString(KEY_FCM_DEVICE_TOKEN_ID, session.fcmDeviceTokenId)
        } else {
            editor.remove(KEY_FCM_DEVICE_TOKEN_ID)
        }

        if (session.apnsVoipToken != null) {
            editor.putString(KEY_APNS_VOIP_TOKEN, session.apnsVoipToken)
        } else {
            editor.remove(KEY_APNS_VOIP_TOKEN)
        }

        editor.apply()
    }

    @Synchronized
    fun saveTokenPair(accessToken: String, refreshToken: String) {
        check(prefs.edit().putString(KEY_ACCESS_TOKEN, accessToken)
            .putString(KEY_REFRESH_TOKEN, refreshToken).commit()) { "Unable to save voice tokens" }
    }

    @Synchronized
    fun getAccessToken(): String? = prefs.getString(KEY_ACCESS_TOKEN, null)

    @Synchronized
    fun setAccessToken(token: String) {
        prefs.edit().putString(KEY_ACCESS_TOKEN, token).apply()
    }

    @Synchronized
    fun getRefreshToken(): String? = prefs.getString(KEY_REFRESH_TOKEN, null)

    @Synchronized
    fun setRefreshToken(token: String?) {
        prefs.edit().putString(KEY_REFRESH_TOKEN, token).apply()
    }

    @Synchronized
    fun getUserId(): String? = prefs.getString(KEY_USER_ID, null)

    @Synchronized
    fun getBaseUrl(): String = prefs.getString(KEY_BASE_URL, "https://api.trymealmate.com") ?: "https://api.trymealmate.com"

    @Synchronized
    fun getHubUrl(): String = prefs.getString(KEY_HUB_URL, "${getBaseUrl()}/hubs/voice-call-v2") ?: "${getBaseUrl()}/hubs/voice-call-v2"

    @Synchronized
    fun getInstallationId(): String = prefs.getString(KEY_INSTALLATION_ID, "voice-device-android") ?: "voice-device-android"

    @Synchronized
    fun getFcmDeviceTokenId(): String? = prefs.getString(KEY_FCM_DEVICE_TOKEN_ID, null)

    @Synchronized
    fun saveDeviceSession(sessionId: String, proof: String, expiresAtUtc: String) {
        prefs.edit()
            .putString(KEY_DEVICE_SESSION_ID, sessionId)
            .putString(KEY_CONTROL_PROOF, proof)
            .putString(KEY_EXPIRES_AT_UTC, expiresAtUtc)
            .apply()
    }

    @Synchronized
    fun getDeviceSessionId(): String? = prefs.getString(KEY_DEVICE_SESSION_ID, null)

    @Synchronized
    fun getControlProof(): String? = prefs.getString(KEY_CONTROL_PROOF, null)

    @Synchronized
    fun getExpiresAtUtc(): String? = prefs.getString(KEY_EXPIRES_AT_UTC, null)

    @Synchronized
    fun clearDeviceSession() {
        prefs.edit()
            .remove(KEY_DEVICE_SESSION_ID)
            .remove(KEY_CONTROL_PROOF)
            .remove(KEY_EXPIRES_AT_UTC)
            .apply()
    }

    @Synchronized
    fun saveCallReconciliation(callId: String, tripStopId: String, clientRequestId: String, endPending: Boolean) {
        prefs.edit()
            .putString(KEY_LAST_CALL_ID, callId)
            .putString(KEY_LAST_TRIP_STOP_ID, tripStopId)
            .putString(KEY_LAST_CLIENT_REQUEST_ID, clientRequestId)
            .putBoolean(KEY_SERVER_END_PENDING, endPending)
            .apply()
    }

    @Synchronized
    fun getLastCallId(): String? = prefs.getString(KEY_LAST_CALL_ID, null)

    @Synchronized
    fun isServerEndPending(): Boolean = prefs.getBoolean(KEY_SERVER_END_PENDING, false)

    @Synchronized
    fun setServerEndPending(pending: Boolean) {
        prefs.edit().putBoolean(KEY_SERVER_END_PENDING, pending).apply()
    }

    @Synchronized
    fun clearCallReconciliation() {
        prefs.edit()
            .remove(KEY_LAST_CALL_ID)
            .remove(KEY_LAST_TRIP_STOP_ID)
            .remove(KEY_LAST_CLIENT_REQUEST_ID)
            .remove(KEY_SERVER_END_PENDING)
            .apply()
    }

    @Synchronized
    fun clearAll() {
        prefs.edit().clear().apply()
    }
}
