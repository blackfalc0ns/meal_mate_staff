package com.mealmate.driver_voice_engine

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.util.Log

class RingbackPlayer(private val context: Context) {

    companion object {
        private const val TAG = "RingbackPlayer"
    }

    private var mediaPlayer: MediaPlayer? = null
    private val lock = Any()
    private var isPlaying = false

    fun start() {
        synchronized(lock) {
            if (isPlaying) return
            try {
                // Find resource id for raw/ringback
                val resId = context.resources.getIdentifier("ringback", "raw", context.packageName)
                if (resId == 0) {
                    Log.w(TAG, "ringback raw resource not found, skipping local tone")
                    return
                }

                val player = MediaPlayer.create(context, resId) ?: return
                player.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                player.isLooping = true
                player.start()

                mediaPlayer = player
                isPlaying = true
                Log.i(TAG, "Ringback tone started")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting ringback: ${e.message}")
            }
        }
    }

    fun stop() {
        synchronized(lock) {
            if (!isPlaying && mediaPlayer == null) return
            try {
                mediaPlayer?.let { player ->
                    if (player.isPlaying) {
                        player.stop()
                    }
                    player.release()
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error stopping ringback player: ${e.message}")
            } finally {
                mediaPlayer = null
                isPlaying = false
                Log.i(TAG, "Ringback tone stopped")
            }
        }
    }
}
