import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'driver_voice_engine_method_channel.dart';

abstract class DriverVoiceEnginePlatform extends PlatformInterface {
  /// Constructs a DriverVoiceEnginePlatform.
  DriverVoiceEnginePlatform() : super(token: _token);

  static final Object _token = Object();

  static DriverVoiceEnginePlatform _instance = MethodChannelDriverVoiceEngine();

  /// The default instance of [DriverVoiceEnginePlatform] to use.
  ///
  /// Defaults to [MethodChannelDriverVoiceEngine].
  static DriverVoiceEnginePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DriverVoiceEnginePlatform] when
  /// they register themselves.
  static set instance(DriverVoiceEnginePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
