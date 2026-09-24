import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/background_notification_content.dart';

void main() {
  group('resolveBackgroundNotificationContent', () {
    test('returns null when the operating system will display the message', () {
      final content = resolveBackgroundNotificationContent(
        hasSystemNotification: true,
        data: const {'title': 'Duplicate'},
      );

      expect(content, isNull);
    });

    test('creates content for a data-only message', () {
      final content = resolveBackgroundNotificationContent(
        hasSystemNotification: false,
        data: const {'title': 'Data title', 'body': 'Data body'},
      );

      expect(content?.title, 'Data title');
      expect(content?.body, 'Data body');
    });

    test('uses safe defaults for an empty data-only message', () {
      final content = resolveBackgroundNotificationContent(
        hasSystemNotification: false,
        data: const {},
      );

      expect(content?.title, 'MealMate');
      expect(content?.body, '');
    });
  });
}
