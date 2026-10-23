import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'driver_voice_engine_platform_interface.dart';

/// An implementation of [DriverVoiceEnginePlatform] that uses method channels.
class MethodChannelDriverVoiceEngine extends DriverVoiceEnginePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('driver_voice_engine');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
