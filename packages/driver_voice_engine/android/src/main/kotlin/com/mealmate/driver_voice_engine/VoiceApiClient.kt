package com.mealmate.driver_voice_engine

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

data class NativeDeviceRegisterResponse(
    val deviceSessionId: String,
    val controlProof: String,
    val expiresAtUtc: String
)

data class NativeCallSnapshotResponse(
    val callId: String,
    val tripStopId: String,
    val status: String,
    val sequence: Int,
    val startedAtUtc: String?,
    val acceptedAtUtc: String?,
    val connectedAtUtc: String?,
    val endedAtUtc: String?,
    val durationSeconds: Int?,
    val deadlineAtUtc: String?,
    val endReason: String?
)

data class NativeIceServer(
    val urls: List<String>,
    val username: String?,
    val credential: String?
)

class VoiceApiClient(private val store: VoiceCallStore) {

    companion object {
        private const val TAG = "VoiceApiClient"
        private const val CONNECT_TIMEOUT_MS = 15000
        private const val READ_TIMEOUT_MS = 15000
    }

    // Flutter owns refresh-token rotation for ALL HTTP and SignalR consumers.
    // Never rotate independently in Android: replaying an old refresh token revokes sessions.
    var tokenProvider: (suspend (String?, Boolean) -> String?)? = null

    suspend fun freshAccessToken(): String? = tokenProvider?.invoke(null, false) ?: if (tokenProvider == null) store.getAccessToken() else null

    suspend fun refreshJwt(rejectedToken: String? = store.getAccessToken()): Boolean {
        val token = tokenProvider?.invoke(rejectedToken, true) ?: return false
        return token.isNotBlank()
    }

    suspend fun registerDevice(
        fcmDeviceTokenId: String,
        installationId: String,
        platform: String,
        capabilityVersion: Int = 2
    ): NativeDeviceRegisterResponse? = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/devices/register"

        val body = JSONObject().apply {
            put("installationId", installationId)
            put("platform", platform)
            put("fcmDeviceTokenId", fcmDeviceTokenId)
            put("capabilityVersion", capabilityVersion)
        }

        val token = store.getAccessToken() ?: return@withContext null
        val headers = mapOf(
            "Content-Type" to "application/json",
            "Authorization" to "Bearer $token"
        )

        try {
            val (code, responseText) = executeHttpRequest(endpoint, "POST", body.toString(), headers)
            if (code in 200..299 && !responseText.isNullOrBlank()) {
                val json = JSONObject(responseText)
                return@withContext NativeDeviceRegisterResponse(
                    deviceSessionId = json.optString("deviceSessionId", ""),
                    controlProof = json.optString("controlProof", ""),
                    expiresAtUtc = json.optString("expiresAtUtc", "")
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "registerDevice failed: ${e.javaClass.simpleName}")
        }
        null
    }

    suspend fun revokeDevice(sessionId: String): Boolean = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/devices/$sessionId/revoke"
        val token = store.getAccessToken() ?: return@withContext false
        val headers = mapOf("Authorization" to "Bearer $token")

        try {
            val (code, _) = executeHttpRequest(endpoint, "POST", null, headers)
            return@withContext code in 200..299
        } catch (_: Exception) {
            false
        }
    }

    suspend fun initiateCall(
        tripStopId: String,
        clientRequestId: String
    ): NativeCallSnapshotResponse? = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/initiate"

        val body = JSONObject().apply {
            put("tripStopId", tripStopId)
            put("clientRequestId", clientRequestId)
        }

        val headers = mutableMapOf(
            "Content-Type" to "application/json",
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )

        try {
            val (code, responseText) = executeHttpRequest(endpoint, "POST", body.toString(), headers)
            if (code in 200..299 && !responseText.isNullOrBlank()) {
                val json = JSONObject(responseText)
                return@withContext parseCallSnapshot(json)
            }
        } catch (e: Exception) {
            Log.e(TAG, "initiateCall error: ${e.javaClass.simpleName}")
        }
        null
    }

    suspend fun cancelCall(callId: String): Boolean = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId/cancel"
        val headers = mutableMapOf(
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )
        try {
            val (code, _) = executeHttpRequest(endpoint, "POST", null, headers)
            code in 200..299 || code == 409
        } catch (_: Exception) {
            false
        }
    }

    suspend fun endCall(callId: String): Boolean = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId/end"
        val headers = mutableMapOf(
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )
        try {
            val (code, _) = executeHttpRequest(endpoint, "POST", null, headers)
            code in 200..299 || code == 409
        } catch (_: Exception) {
            false
        }
    }

    suspend fun getCallSnapshot(callId: String): NativeCallSnapshotResponse? = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId"
        val headers = mutableMapOf(
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )
        try {
            val (code, responseText) = executeHttpRequest(endpoint, "GET", null, headers)
            if (code in 200..299 && !responseText.isNullOrBlank()) {
                return@withContext parseCallSnapshot(JSONObject(responseText))
            }
        } catch (e: Exception) {
            Log.e(TAG, "getCallSnapshot error: ${e.javaClass.simpleName}")
        }
        null
    }

    suspend fun getActiveCall(): NativeCallSnapshotResponse? = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/active"
        val headers = mutableMapOf(
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )
        try {
            val (code, responseText) = executeHttpRequest(endpoint, "GET", null, headers)
            if (code in 200..299 && !responseText.isNullOrBlank()) {
                return@withContext parseCallSnapshot(JSONObject(responseText))
            }
        } catch (e: Exception) {
            Log.e(TAG, "getActiveCall error: ${e.javaClass.simpleName}")
        }
        null
    }

    suspend fun getIceServers(callId: String): List<NativeIceServer>? = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId/ice-servers"
        val headers = mutableMapOf(
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )
        try {
            val (code, responseText) = executeHttpRequest(endpoint, "GET", null, headers)
            if (code in 200..299 && !responseText.isNullOrBlank()) {
                val json = JSONObject(responseText)
                val serversArr = json.optJSONArray("iceServers") ?: JSONArray()
                val list = mutableListOf<NativeIceServer>()
                for (i in 0 until serversArr.length()) {
                    val s = serversArr.getJSONObject(i)
                    val urlsArr = s.optJSONArray("urls") ?: JSONArray()
                    val urls = mutableListOf<String>()
                    for (u in 0 until urlsArr.length()) {
                        urls.add(urlsArr.getString(u))
                    }
                    list.add(
                        NativeIceServer(
                            urls = urls,
                            username = s.optString("username", null),
                            credential = s.optString("credential", null)
                        )
                    )
                }
                return@withContext list
            }
        } catch (e: Exception) {
            Log.e(TAG, "getIceServers error: ${e.javaClass.simpleName}")
        }
        null
    }

    suspend fun reportConnecting(callId: String): Boolean = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId/reports/connecting"
        postReport(endpoint)
    }

    suspend fun reportConnected(callId: String): Boolean = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId/reports/connected"
        postReport(endpoint)
    }

    suspend fun sendHeartbeat(callId: String): Boolean = withContext(Dispatchers.IO) {
        val baseUrl = store.getBaseUrl()
        val endpoint = "$baseUrl/api/v2/voice-calls/$callId/heartbeat"
        postReport(endpoint)
    }

    private suspend fun postReport(endpoint: String): Boolean {
        val headers = mutableMapOf(
            "Authorization" to "Bearer ${store.getAccessToken() ?: ""}",
            "X-Voice-Device-Session" to (store.getDeviceSessionId() ?: ""),
            "X-Voice-Device-Proof" to (store.getControlProof() ?: "")
        )
        return try {
            val (code, _) = executeHttpRequest(endpoint, "POST", null, headers)
            code in 200..299
        } catch (_: Exception) {
            false
        }
    }

    private fun parseCallSnapshot(json: JSONObject): NativeCallSnapshotResponse {
        return NativeCallSnapshotResponse(
            callId = json.optString("callId", ""),
            tripStopId = json.optString("tripStopId", ""),
            status = json.optString("status", "Created"),
            sequence = json.optInt("sequence", 0),
            startedAtUtc = json.optString("startedAtUtc", null),
            acceptedAtUtc = json.optString("acceptedAtUtc", null),
            connectedAtUtc = json.optString("connectedAtUtc", null),
            endedAtUtc = json.optString("endedAtUtc", null),
            durationSeconds = if (json.has("durationSeconds")) json.optInt("durationSeconds") else null,
            deadlineAtUtc = json.optString("deadlineAtUtc", null),
            endReason = json.optString("endReason", null)
        )
    }

    private suspend fun executeHttpRequest(
        urlStr: String, method: String, body: String?, headers: Map<String, String>
    ): Pair<Int, String?> {
        val provider = tokenProvider
        if (provider != null && provider(null, false).isNullOrBlank()) return Pair(503, null)
        val sentToken = store.getAccessToken()
        val updatedHeaders = headers.toMutableMap()
        updatedHeaders["Authorization"] = "Bearer ${sentToken ?: ""}"
        var result = try {
            executeRawHttpRequest(urlStr, method, body, updatedHeaders)
        } catch (error: java.io.IOException) {
            if (!urlStr.endsWith("/voice-calls/initiate")) throw error
            // Response may have been lost after server commit. Replay the SAME operation key.
            executeRawHttpRequest(urlStr, method, body, updatedHeaders)
        }
        val refreshRequired = result.first == 401 || (result.first == 409 &&
            urlStr.endsWith("/voice-calls/initiate") && runCatching {
                val problem = JSONObject(result.second ?: "{}")
                (problem.optString("code") == "calls.auth_refresh_required") ||
                    (problem.optJSONObject("extensions")?.optString("code") == "calls.auth_refresh_required")
            }.getOrDefault(false))
        if (refreshRequired && refreshJwt(sentToken)) {
            updatedHeaders["Authorization"] = "Bearer ${store.getAccessToken() ?: ""}"
            result = executeRawHttpRequest(urlStr, method, body, updatedHeaders)
        }
        return result
    }

    private fun executeRawHttpRequest(
        urlStr: String,
        method: String,
        body: String?,
        headers: Map<String, String>
    ): Pair<Int, String?> {
        val url = URL(urlStr)
        val conn = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = method
            connectTimeout = CONNECT_TIMEOUT_MS
            readTimeout = READ_TIMEOUT_MS
            doInput = true
            headers.forEach { (k, v) -> setRequestProperty(k, v) }
        }

        if (body != null && (method == "POST" || method == "PUT")) {
            conn.doOutput = true
            conn.outputStream.use { os ->
                OutputStreamWriter(os, Charsets.UTF_8).use { writer ->
                    writer.write(body)
                    writer.flush()
                }
            }
        }

        val code = conn.responseCode
        val isSuccess = code in 200..299
        val inputStream = if (isSuccess) conn.inputStream else conn.errorStream
        val response = inputStream?.let { stream ->
            BufferedReader(InputStreamReader(stream, Charsets.UTF_8)).use { it.readText() }
        }
        conn.disconnect()
        return Pair(code, response)
    }
}
