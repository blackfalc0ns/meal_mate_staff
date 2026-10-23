package com.mealmate.driver_voice_engine

import android.content.Context
import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

class DriverVoiceEnginePlugin : FlutterPlugin, DriverVoiceHostApi, ActivityAware, PluginRegistry.RequestPermissionsResultListener {

    private var authBridge: VoiceAuthBridge? = null
    private var context: Context? = null
    private var coordinator: NativeCallCoordinator? = null
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingStart: (() -> Unit)? = null
    private var pendingPermissionFailure: (() -> Unit)? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        val coord = NativeCallCoordinator.getInstance(binding.applicationContext)
        coordinator = coord
        authBridge = VoiceAuthBridge(binding.binaryMessenger, coord)
        coord.flutterApi = DriverVoiceFlutterApi(binding.binaryMessenger)

        DriverVoiceHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        DriverVoiceHostApi.setUp(binding.binaryMessenger, null)
        authBridge?.dispose()
        authBridge = null
        coordinator?.flutterApi = null
        coordinator = null
        context = null
    }

    override fun getCapabilities(): DriverVoiceEngineCapabilities {
        return DriverVoiceEngineCapabilities(
            supportsTelecom = true,
            supportsCallKit = false,
            supportsProximity = true,
            supportsBluetoothRouting = true
        )
    }

    override fun getCurrentCall(): DriverVoiceCallSnapshot? {
        val coord = coordinator ?: return null
        val snapshot = coord.getCurrentSnapshot()
        return if (snapshot.serverStatus != DriverVoiceServerCallStatus.IDLE) {
            snapshot
        } else {
            null
        }
    }

    override fun startOutgoing(
        request: DriverVoiceStartOutgoingRequest,
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        val coord = coordinator
        if (coord == null) {
            callback(Result.success(DriverVoiceCommandResult(
                status = DriverVoiceCommandStatus.PREPARATION_FAILED,
                errorMessage = "Engine coordinator not attached"
            )))
            return
        }
        if (ContextCompat.checkSelfPermission(context!!, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
            coord.startOutgoing(request, callback)
            return
        }
        val host = activity
        if (host == null || pendingStart != null) {
            callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.PREPARATION_FAILED, errorMessage = "Microphone permission unavailable")))
            return
        }
        pendingStart = { coord.startOutgoing(request, callback) }
        pendingPermissionFailure = {
            callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.PREPARATION_FAILED, errorMessage = "Microphone permission is required for voice calls")))
        }
        ActivityCompat.requestPermissions(host, arrayOf(Manifest.permission.RECORD_AUDIO), 4102)
    }

    override fun setMuted(
        muted: Boolean,
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        val coord = coordinator
        if (coord == null) {
            callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.PREPARATION_FAILED)))
            return
        }
        coord.setMuted(muted, callback)
    }

    override fun selectAudioRoute(
        route: DriverVoiceAudioRoute,
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        val coord = coordinator
        if (coord == null) {
            callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.PREPARATION_FAILED)))
            return
        }
        coord.selectAudioRoute(route, callback)
    }

    override fun hangUp(
        reason: String?,
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        val coord = coordinator
        if (coord == null) {
            callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.SUCCESS)))
            return
        }
        coord.hangUp(reason, callback)
    }

    override fun syncAccountSession(
        session: DriverVoiceAccountSession,
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        val coord = coordinator
        if (coord == null) {
            callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.PREPARATION_FAILED)))
            return
        }
        coord.store.saveAccountSession(session)
        callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.SUCCESS)))
    }

    override fun revokeAccountSession(
        callback: (Result<DriverVoiceCommandResult>) -> Unit
    ) {
        val coord = coordinator
        if (coord != null) {
            coord.terminateLocalSession()
        }
        callback(Result.success(DriverVoiceCommandResult(status = DriverVoiceCommandStatus.SUCCESS)))
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }
    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
    }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    override fun onDetachedFromActivity() {
        onDetachedFromActivityForConfigChanges()
        val fail = pendingPermissionFailure
        pendingStart = null
        pendingPermissionFailure = null
        fail?.invoke()
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode != 4102) return false
        val start = pendingStart
        val fail = pendingPermissionFailure
        pendingStart = null
        pendingPermissionFailure = null
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) start?.invoke() else fail?.invoke()
        return true
    }
}
