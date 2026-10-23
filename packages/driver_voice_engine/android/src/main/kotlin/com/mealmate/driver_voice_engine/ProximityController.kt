package com.mealmate.driver_voice_engine

import android.content.Context
import android.os.PowerManager
import android.util.Log

class ProximityController(private val context: Context) {

    companion object {
        private const val TAG = "ProximityController"
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private val lock = Any()

    fun enable() {
        synchronized(lock) {
            if (wakeLock != null && wakeLock?.isHeld == true) return
            try {
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return
                val field = PowerManager::class.java.getField("PROXIMITY_SCREEN_OFF_WAKE_LOCK")
                val proximityWakeLockFlag = field.getInt(null)

                val isSupported = powerManager.isWakeLockLevelSupported(proximityWakeLockFlag)
                if (!isSupported) {
                    Log.d(TAG, "Proximity screen off wake lock is not supported on this device")
                    return
                }

                val wl = powerManager.newWakeLock(proximityWakeLockFlag, "mealmate:voice_proximity")
                wl.acquire(60 * 60 * 1000L) // 1 hour max safeguard
                wakeLock = wl
                Log.d(TAG, "Proximity sensor wake lock acquired")
            } catch (e: Exception) {
                Log.d(TAG, "Proximity sensor activation unavailable: ${e.message}")
            }
        }
    }

    fun disable() {
        synchronized(lock) {
            try {
                if (wakeLock?.isHeld == true) {
                    wakeLock?.release(PowerManager.RELEASE_FLAG_WAIT_FOR_NO_PROXIMITY)
                    Log.d(TAG, "Proximity sensor wake lock released")
                }
            } catch (e: Exception) {
                try {
                    wakeLock?.release()
                } catch (_: Exception) {}
            } finally {
                wakeLock = null
            }
        }
    }
}
