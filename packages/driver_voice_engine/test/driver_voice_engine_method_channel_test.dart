import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_voice_engine/driver_voice_engine_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDriverVoiceEngine platform = MethodChannelDriverVoiceEngine();
  const MethodChannel channel = MethodChannel('driver_voice_engine');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
