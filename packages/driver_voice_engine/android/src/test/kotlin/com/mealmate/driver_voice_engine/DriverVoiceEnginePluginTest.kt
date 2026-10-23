package com.mealmate.driver_voice_engine

import kotlin.test.Test
import kotlin.test.assertNotNull

internal class DriverVoiceEnginePluginTest {
    @Test
    fun pluginInstantiation_succeeds() {
        val plugin = DriverVoiceEnginePlugin()
        assertNotNull(plugin)
    }
}
