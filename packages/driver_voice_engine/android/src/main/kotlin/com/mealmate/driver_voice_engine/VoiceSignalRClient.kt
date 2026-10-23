package com.mealmate.driver_voice_engine

import android.util.Log
import kotlinx.coroutines.*
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

class VoiceSignalRClient(
    private val store: VoiceCallStore,
    private val apiClient: VoiceApiClient? = null,
    private val onReconnected: (() -> Unit)? = null
) {
    companion object {
        private const val TAG = "VoiceSignalRClient"
        private const val RECORD_SEPARATOR = 0x1E.toChar()
    }

    interface Listener {
        fun onBound()
        fun onCallEvent(envelope: JSONObject)
        fun onOffer(callId: String, sdp: String, messageId: String, generation: Int)
        fun onAnswer(callId: String, sdp: String, messageId: String, generation: Int)
        fun onIceCandidate(
            callId: String,
            candidate: String,
            sdpMid: String?,
            sdpMLineIndex: Int?,
            usernameFragment: String?,
            messageId: String,
            generation: Int
        )
        fun onConnectionStateChanged(connected: Boolean)
    }

    var listener: Listener? = null

    @Volatile private var isConnected = false
    @Volatile private var isBound = false
    @Volatile private var boundSessionId: String? = null
    private val invocationId = AtomicInteger(1)
    private var isExplicitlyDisconnected = false
    @Volatile private var isConnecting = false
    @Volatile private var connectionEpoch = 0
    private var reconnectJob: Job? = null

    private var webSocket: okhttp3.WebSocket? = null
    private var okHttpClient: okhttp3.OkHttpClient? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    fun isConnected(): Boolean = isConnected
    fun isBound(): Boolean = isBound

    suspend fun connectAndAwaitBound(timeoutMs: Long = 15000): Boolean {
        if (isBound && boundSessionId == store.getDeviceSessionId()) return true
        if (isConnected) {
            isBound = false
            boundSessionId = null
            val sessionId = store.getDeviceSessionId()
            val proof = store.getControlProof()
            if (sessionId.isNullOrBlank() || proof.isNullOrBlank()) return false
            bindDeviceSession(sessionId, proof)
        } else connect()
        val ready = withTimeoutOrNull(timeoutMs) {
            while (!isBound || boundSessionId != store.getDeviceSessionId()) delay(50)
            true
        } ?: false
        if (!ready) disconnect()
        return ready
    }

    @Synchronized fun connect() {
        if (isConnecting || isConnected) return
        isConnecting = true
        val epoch = ++connectionEpoch
        isExplicitlyDisconnected = false
        scope.launch {
            var token = if (apiClient != null) apiClient.freshAccessToken() else store.getAccessToken()
            if (token.isNullOrBlank()) {
                Log.w(TAG, "Cannot connect: access token is missing")
                isConnecting = false
                return@launch
            }

            val hubUrl = store.getHubUrl()
            if (hubUrl.isBlank()) {
                Log.w(TAG, "Cannot connect: hubUrl is blank")
                isConnecting = false
                return@launch
            }

            val client = okhttp3.OkHttpClient.Builder()
                .connectTimeout(10, java.util.concurrent.TimeUnit.SECONDS)
                .readTimeout(0, java.util.concurrent.TimeUnit.MILLISECONDS)
                .build()
            okHttpClient = client

            val cleanHubUrl = if (hubUrl.endsWith("/")) hubUrl.substring(0, hubUrl.length - 1) else hubUrl
            val negotiateUrl = "$cleanHubUrl/negotiate?negotiateVersion=1"
            var connectionToken: String? = null
            var resolvedWsUrl: String? = null
            var resolvedToken = token

            val emptyBody = okhttp3.RequestBody.create(null, ByteArray(0))
            val negotiateReq = okhttp3.Request.Builder()
                .url(negotiateUrl)
                .post(emptyBody)
                .header("Authorization", "Bearer $resolvedToken")
                .build()

            try {
                val resp = client.newCall(negotiateReq).execute()
                if (resp.code == 401) {
                    Log.w(TAG, "Negotiate returned 401, attempting token refresh...")
                    val refreshed = apiClient?.refreshJwt(token) ?: false
                    if (refreshed) {
                        val newToken = store.getAccessToken()
                        if (!newToken.isNullOrBlank()) {
                            resolvedToken = newToken
                            val retryReq = okhttp3.Request.Builder()
                                .url(negotiateUrl)
                                .post(emptyBody)
                                .header("Authorization", "Bearer $resolvedToken")
                                .build()
                            val retryResp = client.newCall(retryReq).execute()
                            if (retryResp.isSuccessful) {
                                val bodyStr = retryResp.body?.string().orEmpty()
                                val json = JSONObject(bodyStr)
                                if (json.has("url") && json.optString("url").isNotBlank()) {
                                    resolvedWsUrl = json.getString("url")
                                    if (json.has("accessToken")) {
                                        resolvedToken = json.getString("accessToken")
                                    }
                                }
                                connectionToken = json.optString("connectionToken", json.optString("connectionId", ""))
                                Log.i(TAG, "Negotiate succeeded on retry after refresh")
                            } else {
                                Log.w(TAG, "Negotiate retry failed: ${retryResp.code}")
                            }
                        }
                    }
                } else if (resp.isSuccessful) {
                    val bodyStr = resp.body?.string().orEmpty()
                    val json = JSONObject(bodyStr)
                    if (json.has("url") && json.optString("url").isNotBlank()) {
                        resolvedWsUrl = json.getString("url")
                        if (json.has("accessToken")) {
                            resolvedToken = json.getString("accessToken")
                        }
                    }
                    connectionToken = json.optString("connectionToken", json.optString("connectionId", ""))
                    Log.i(TAG, "Negotiate succeeded, connectionToken acquired")
                } else {
                    Log.w(TAG, "Negotiate HTTP response code: ${resp.code}")
                }
            } catch (e: Exception) {
                Log.w(TAG, "Negotiate request exception: ${e.javaClass.simpleName}")
            }

            val baseWsUrl = resolvedWsUrl ?: if (cleanHubUrl.startsWith("https://")) {
                cleanHubUrl.replaceFirst("https://", "wss://")
            } else if (cleanHubUrl.startsWith("http://")) {
                cleanHubUrl.replaceFirst("http://", "ws://")
            } else {
                cleanHubUrl
            }

            val encodedToken = URLEncoder.encode(resolvedToken, "UTF-8")
            val wsUrl = if (!connectionToken.isNullOrBlank()) {
                val encodedConnToken = URLEncoder.encode(connectionToken, "UTF-8")
                if (baseWsUrl.contains("?")) {
                    "$baseWsUrl&id=$encodedConnToken&access_token=$encodedToken"
                } else {
                    "$baseWsUrl?id=$encodedConnToken&access_token=$encodedToken"
                }
            } else {
                if (baseWsUrl.contains("?")) {
                    "$baseWsUrl&access_token=$encodedToken"
                } else {
                    "$baseWsUrl?access_token=$encodedToken"
                }
            }

            val request = okhttp3.Request.Builder()
                .url(wsUrl)
                .header("Authorization", "Bearer $resolvedToken")
                .build()

            if (epoch != connectionEpoch || isExplicitlyDisconnected) return@launch
            webSocket = client.newWebSocket(request, object : okhttp3.WebSocketListener() {
                override fun onOpen(webSocket: okhttp3.WebSocket, response: okhttp3.Response) {
                    if (epoch != connectionEpoch) { webSocket.cancel(); return }
                    Log.i(TAG, "WebSocket opened, sending SignalR handshake")
                    val handshake = "{\"protocol\":\"json\",\"version\":1}$RECORD_SEPARATOR"
                    webSocket.send(handshake)
                }

                override fun onMessage(webSocket: okhttp3.WebSocket, text: String) {
                    if (epoch != connectionEpoch) return
                    handleIncomingMessages(text)
                }

                override fun onClosing(webSocket: okhttp3.WebSocket, code: Int, reason: String) {
                    webSocket.close(code, reason)
                }

                override fun onClosed(webSocket: okhttp3.WebSocket, code: Int, reason: String) {
                    if (epoch != connectionEpoch) return
                    Log.i(TAG, "WebSocket closed: $code")
                    isConnected = false
                    isConnecting = false
                    isBound = false
                    boundSessionId = null
                    listener?.onConnectionStateChanged(false)
                    scheduleReconnect()
                }

                override fun onFailure(webSocket: okhttp3.WebSocket, t: Throwable, response: okhttp3.Response?) {
                    if (epoch != connectionEpoch) return
                    Log.w(TAG, "WebSocket failure: ${t.javaClass.simpleName} (HTTP ${response?.code})")
                    isConnected = false
                    isConnecting = false
                    isBound = false
                    boundSessionId = null
                    listener?.onConnectionStateChanged(false)
                    // Auto-reconnect after 3 seconds if not explicitly disconnected
                    scheduleReconnect()
                }
            })
        }
    }

    private fun scheduleReconnect() {
        if (isExplicitlyDisconnected || reconnectJob?.isActive == true) return
        reconnectJob = scope.launch {
            delay(3000)
            if (!isExplicitlyDisconnected) connect()
        }
    }

    private fun handleIncomingMessages(rawText: String) {
        val messages = rawText.split(RECORD_SEPARATOR)
        for (msg in messages) {
            val trimmed = msg.trim()
            if (trimmed.isEmpty()) continue
            try {
                val json = JSONObject(trimmed)
                // Type 6 = Ping -> respond with Ping
                if (json.optInt("type") == 6) {
                    webSocket?.send("{\"type\":6}$RECORD_SEPARATOR")
                    continue
                }
                // Handshake response {}
                if (json.length() == 0) {
                    Log.i(TAG, "SignalR Handshake completed successfully")
                    isConnected = true
                    isConnecting = false
                    listener?.onConnectionStateChanged(true)
                    // Auto-bind device session
                    val sid = store.getDeviceSessionId()
                    val proof = store.getControlProof()
                    if (!sid.isNullOrBlank() && !proof.isNullOrBlank()) {
                        bindDeviceSession(sid, proof)
                    }
                    continue
                }
                // Type 1 = Invocation
                if (json.optInt("type") == 1) {
                    val target = json.optString("target", "")
                    val args = json.optJSONArray("arguments") ?: JSONArray()
                    dispatchInvocation(target, args)
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error parsing incoming SignalR frame: ${e.javaClass.simpleName}")
            }
        }
    }

    private fun dispatchInvocation(target: String, args: JSONArray) {
        when (target) {
            "bound" -> {
                Log.i(TAG, "bound confirmation received")
                isBound = true
                boundSessionId = store.getDeviceSessionId()
                listener?.onBound()
            }
            "call:event", "OnCallEvent", "CallEvent" -> {
                if (args.length() > 0) {
                    val first = args.optJSONObject(0)
                    if (first != null) {
                        listener?.onCallEvent(first)
                    }
                }
            }
            "rtc:offer", "OnOffer", "Offer" -> {
                parseRtcOffer(args)
            }
            "rtc:answer", "OnAnswer", "Answer" -> {
                parseRtcAnswer(args)
            }
            "rtc:ice-candidate", "OnIceCandidate", "IceCandidate", "rtc:ice" -> {
                parseRtcIce(args)
            }
        }
    }

    private fun parseRtcOffer(args: JSONArray) {
        val decoded = decodeRtcEnvelope(args) ?: return
        val sdp = decoded.payload.optString("sdp", "")
        if (sdp.isNotBlank()) {
            listener?.onOffer(decoded.callId, sdp, decoded.messageId, decoded.generation)
        }
    }

    private fun parseRtcAnswer(args: JSONArray) {
        val decoded = decodeRtcEnvelope(args) ?: return
        val sdp = decoded.payload.optString("sdp", "")
        if (sdp.isNotBlank()) {
            listener?.onAnswer(decoded.callId, sdp, decoded.messageId, decoded.generation)
        }
    }

    private fun parseRtcIce(args: JSONArray) {
        val decoded = decodeRtcEnvelope(args) ?: return
        val candidate = decoded.payload.optString("candidate", "")
        if (candidate.isNotBlank()) {
            listener?.onIceCandidate(
                callId = decoded.callId,
                candidate = candidate,
                sdpMid = decoded.payload.optString("sdpMid", null),
                sdpMLineIndex = if (decoded.payload.has("sdpMLineIndex")) decoded.payload.optInt("sdpMLineIndex") else null,
                usernameFragment = decoded.payload.optString("usernameFragment", null),
                messageId = decoded.messageId,
                generation = decoded.generation
            )
        }
    }

    private data class DecodedRtc(
        val callId: String,
        val messageId: String,
        val generation: Int,
        val payload: JSONObject
    )

    private fun decodeRtcEnvelope(args: JSONArray): DecodedRtc? {
        if (args.length() >= 4) {
            val callId = args.optString(0, "")
            val payload = args.optJSONObject(1) ?: JSONObject()
            val messageId = args.optString(2, "")
            val generation = args.optInt(3, 0)
            return DecodedRtc(callId, messageId, generation, payload)
        } else if (args.length() == 1) {
            val env = args.optJSONObject(0) ?: return null
            val callId = env.optString("callId", "")
            val messageId = env.optString("messageId", "")
            val gen = if (env.has("negotiationGeneration")) env.optInt("negotiationGeneration") else env.optInt("generation", 0)
            val payload = env.optJSONObject("payload") ?: JSONObject()
            return DecodedRtc(callId, messageId, gen, payload)
        }
        return null
    }

    fun bindDeviceSession(sessionId: String, controlProof: String) {
        val args = JSONArray().apply {
            put(sessionId)
            put(controlProof)
        }
        sendHubInvocation("BindDeviceSession", args)
    }

    fun sendOffer(callId: String, sdp: String, messageId: String, generation: Int): Boolean {
        val payload = JSONObject().apply {
            put("type", "offer")
            put("sdp", sdp)
        }
        val args = JSONArray().apply {
            put(callId)
            put(payload)
            put(messageId)
            put(generation)
        }
        return sendHubInvocation("SendOffer", args)
    }

    fun sendAnswer(callId: String, sdp: String, messageId: String, generation: Int) {
        val payload = JSONObject().apply {
            put("type", "answer")
            put("sdp", sdp)
        }
        val args = JSONArray().apply {
            put(callId)
            put(payload)
            put(messageId)
            put(generation)
        }
        sendHubInvocation("SendAnswer", args)
    }

    fun sendIceCandidate(
        callId: String,
        candidate: String,
        sdpMid: String?,
        sdpMLineIndex: Int?,
        usernameFragment: String?,
        messageId: String,
        generation: Int
    ) {
        val payload = JSONObject().apply {
            put("candidate", candidate)
            if (sdpMid != null) put("sdpMid", sdpMid)
            if (sdpMLineIndex != null) put("sdpMLineIndex", sdpMLineIndex)
            if (usernameFragment != null) put("usernameFragment", usernameFragment)
        }
        val args = JSONArray().apply {
            put(callId)
            put(payload)
            put(messageId)
            put(generation)
        }
        sendHubInvocation("SendIceCandidate", args)
    }

    private fun sendHubInvocation(target: String, args: JSONArray): Boolean {
        if (!isConnected || (target != "BindDeviceSession" && !isBound)) return false
        val id = invocationId.getAndIncrement().toString()
        val msg = JSONObject().apply {
            put("type", 1)
            put("invocationId", id)
            put("target", target)
            put("arguments", args)
        }
        return webSocket?.send(msg.toString() + RECORD_SEPARATOR) == true
    }

    fun disconnect() {
        isExplicitlyDisconnected = true
        connectionEpoch++
        isConnecting = false
        reconnectJob?.cancel()
        try {
            webSocket?.close(1000, "Normal Closure")
        } catch (_: Exception) {}
        webSocket = null
        isConnected = false
        isBound = false
        boundSessionId = null
    }
}
