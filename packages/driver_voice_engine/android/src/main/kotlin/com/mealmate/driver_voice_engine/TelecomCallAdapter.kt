package com.mealmate.driver_voice_engine

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.core.app.NotificationCompat

class TelecomCallAdapter(private val context: Context) {

    companion object {
        private const val TAG = "TelecomCallAdapter"
        // A new channel applies the quiet policy even on existing installations.
        const val CHANNEL_ID = "mealmate_active_voice_calls_quiet_v2"
        const val NOTIFICATION_ID = 4001

        const val ACTION_HANGUP = "com.mealmate.driver_voice_engine.ACTION_HANGUP"
        const val ACTION_TOGGLE_MUTE = "com.mealmate.driver_voice_engine.ACTION_TOGGLE_MUTE"
        const val ACTION_RETURN_TO_CALL = "com.mealmate.driver_voice_engine.ACTION_RETURN_TO_CALL"
        const val EXTRA_CALL_ID = "call_id"
    }

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val notificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Active Voice Calls",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Ongoing delivery voice call controls"
                setSound(null, null)
                enableVibration(false)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun buildCallNotification(
        callId: String,
        customerName: String,
        statusText: String,
        isMuted: Boolean,
        connectedAtUtcMs: Long?
    ): Notification {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_CALL_ID, callId)
        }
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            1,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val hangupIntent = Intent(context, VoiceCallReceiver::class.java).apply {
            action = ACTION_HANGUP
            putExtra(EXTRA_CALL_ID, callId)
        }
        val hangupPendingIntent = PendingIntent.getBroadcast(
            context,
            2,
            hangupIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val muteIntent = Intent(context, VoiceCallReceiver::class.java).apply {
            action = ACTION_TOGGLE_MUTE
            putExtra(EXTRA_CALL_ID, callId)
        }
        val mutePendingIntent = PendingIntent.getBroadcast(
            context,
            3,
            muteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(customerName)
            .setContentText(statusText)
            .setSmallIcon(android.R.drawable.sym_call_outgoing)
            .setOngoing(true)
            .setContentIntent(contentPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "End Call",
                hangupPendingIntent
            )
            .addAction(
                if (isMuted) android.R.drawable.ic_lock_silent_mode_off else android.R.drawable.ic_lock_silent_mode,
                if (isMuted) "Unmute" else "Mute",
                mutePendingIntent
            )

        if (connectedAtUtcMs != null && connectedAtUtcMs > 0) {
            builder.setUsesChronometer(true)
            val elapsedRealtimeNow = SystemClock.elapsedRealtime()
            val wallClockNow = System.currentTimeMillis()
            val baseElapsed = elapsedRealtimeNow - (wallClockNow - connectedAtUtcMs)
            builder.setWhen(baseElapsed)
        }

        return builder.build()
    }

    fun setMuted(muted: Boolean) {
        try {
            audioManager.isMicrophoneMute = muted
            Log.d(TAG, "Audio manager microphone mute set to $muted")
        } catch (e: Exception) {
            Log.w(TAG, "Failed to set microphone mute: ${e.message}")
        }
    }

    fun selectAudioRoute(route: DriverVoiceAudioRoute) {
        try {
            when (route) {
                DriverVoiceAudioRoute.SPEAKER -> {
                    audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                    audioManager.isSpeakerphoneOn = true
                }
                DriverVoiceAudioRoute.EARPIECE -> {
                    audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                    audioManager.isSpeakerphoneOn = false
                }
                DriverVoiceAudioRoute.BLUETOOTH -> {
                    audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val devices = audioManager.availableCommunicationDevices
                        val btDevice = devices.firstOrNull { it.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO || it.type == AudioDeviceInfo.TYPE_BLE_HEADSET }
                        if (btDevice != null) {
                            audioManager.setCommunicationDevice(btDevice)
                        }
                    } else {
                        @Suppress("DEPRECATION")
                        audioManager.startBluetoothSco()
                        @Suppress("DEPRECATION")
                        audioManager.isBluetoothScoOn = true
                    }
                }
                else -> {
                    audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                    audioManager.isSpeakerphoneOn = false
                }
            }
            Log.d(TAG, "Audio route changed to $route")
        } catch (e: Exception) {
            Log.w(TAG, "Error selecting audio route: ${e.message}")
        }
    }

    fun cancelNotification() {
        notificationManager.cancel(NOTIFICATION_ID)
    }

    fun releaseAudio() {
        audioManager.isMicrophoneMute = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) audioManager.clearCommunicationDevice()
        else {
            @Suppress("DEPRECATION")
            audioManager.stopBluetoothSco()
        }
        audioManager.isSpeakerphoneOn = false
        audioManager.mode = AudioManager.MODE_NORMAL
    }
}
