import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getCapabilities test', (WidgetTester tester) async {
    final caps = await DriverVoiceEngine.instance.getCapabilities();
    expect(caps, isNotNull);
  });
}
