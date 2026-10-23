package com.mealmate.driver_voice_engine

import android.content.Context
import android.content.Intent
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.*
import kotlin.test.Test

class VoiceCallServiceTest {
    @Test
    fun stoppingCallServiceDoesNotStartAnotherService() {
        val context = mock(Context::class.java)

        VoiceCallService.stop(context)

        verify(context).stopService(any(Intent::class.java))
        verify(context, never()).startService(any(Intent::class.java))
    }
}
