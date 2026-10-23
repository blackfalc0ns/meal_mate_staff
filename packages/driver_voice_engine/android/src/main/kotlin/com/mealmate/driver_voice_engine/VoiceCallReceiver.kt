package com.mealmate.driver_voice_engine

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class VoiceCallReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "VoiceCallReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val callId = intent.getStringExtra(TelecomCallAdapter.EXTRA_CALL_ID)
        Log.i(TAG, "Notification action received: $action for callId: $callId")

        val coordinator = NativeCallCoordinator.getInstance(context)

        when (action) {
            TelecomCallAdapter.ACTION_HANGUP -> {
                coordinator.hangUp("notification_end_action")
            }
            TelecomCallAdapter.ACTION_TOGGLE_MUTE -> {
                coordinator.toggleMute()
            }
        }
    }
}
