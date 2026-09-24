import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/fcm_token_debug_logger.dart';

void main() {
  group('logFcmTokenForDebug', () {
    test(
      'does not load or expose the token when logging is disabled',
      () async {
        var loadCalls = 0;
        final logs = <String>[];

        await logFcmTokenForDebug(
          enabled: false,
          loadToken: () async {
            loadCalls++;
            return 'secret-token';
          },
          writeLog: logs.add,
        );

        expect(loadCalls, 0);
        expect(logs, isEmpty);
      },
    );

    test('writes the current token with a recognizable debug tag', () async {
      final logs = <String>[];

      await logFcmTokenForDebug(
        enabled: true,
        loadToken: () async => 'current-fcm-token',
        writeLog: logs.add,
      );

      expect(logs, [
        '\x1B[33m[FCMToken] FCM token retrieved: current-fcm-token\x1B[0m',
      ]);
    });
  });
}
