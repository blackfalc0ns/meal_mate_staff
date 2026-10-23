import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DriverVoiceEngine.instance returns a singleton', () {
    final instance1 = DriverVoiceEngine.instance;
    final instance2 = DriverVoiceEngine.instance;
    expect(instance1, isNotNull);
    expect(identical(instance1, instance2), isTrue);
  });
}
