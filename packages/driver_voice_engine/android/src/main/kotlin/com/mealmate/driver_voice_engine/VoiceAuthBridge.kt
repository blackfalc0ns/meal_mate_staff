package com.mealmate.driver_voice_engine

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlin.coroutines.resume

/** Shares the one rotating refresh operation with Dart; never logs credentials. */
class VoiceAuthBridge(messenger: BinaryMessenger, private val coordinator: NativeCallCoordinator) {
    private val channel = MethodChannel(messenger, "mealmate/auth_session")
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private val provider: suspend (String?, Boolean) -> String? = { rejected, force -> requestToken(rejected, force) }

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "activate" -> {
                    // Background FCM engines must not replace the application's refresh owner.
                    coordinator.apiClient.tokenProvider = provider
                    result.success(null)
                }
                "syncTokens" -> {
                    val access = call.argument<String>("accessToken")
                    val refresh = call.argument<String>("refreshToken")
                    if (access.isNullOrBlank() || refresh.isNullOrBlank()) {
                        result.error("invalid_tokens", "Incomplete token pair", null)
                    } else {
                        coordinator.store.saveTokenPair(access, refresh)
                        result.success(null)
                    }
                }
                "syncVoiceDevice" -> {
                    val sessionId = call.argument<String>("deviceSessionId")
                    val proof = call.argument<String>("controlProof")
                    val expiry = call.argument<String>("expiresAtUtc")
                    if (sessionId.isNullOrBlank() || proof.isNullOrBlank() || expiry.isNullOrBlank()) {
                        result.error("invalid_voice_session", "Incomplete owned voice session", null)
                    } else {
                        coordinator.store.saveDeviceSession(sessionId, proof, expiry)
                        result.success(null)
                    }
                }
                "terminateLocal" -> {
                    coordinator.terminateLocalSession()
                    result.success(null)
                }
                "reconcile" -> {
                    scope.launch { coordinator.reconcileSession() }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private suspend fun requestToken(rejected: String?, force: Boolean): String? =
        withContext(Dispatchers.Main) {
            withTimeoutOrNull(20000) {
                suspendCancellableCoroutine { continuation ->
                    channel.invokeMethod("getToken", mapOf("rejectedToken" to rejected, "force" to force),
                        object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                if (continuation.isActive) continuation.resume(result as? String)
                            }
                            override fun error(code: String, message: String?, details: Any?) {
                                if (continuation.isActive) continuation.resume(null)
                            }
                            override fun notImplemented() {
                                if (continuation.isActive) continuation.resume(null)
                            }
                        })
                }
            }
        }

    fun dispose() {
        channel.setMethodCallHandler(null)
        if (coordinator.apiClient.tokenProvider === provider) coordinator.apiClient.tokenProvider = null
        scope.cancel()
    }
}
