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

    test('does not display an empty data-only message', () {
      final content = resolveBackgroundNotificationContent(
        hasSystemNotification: false,
        data: const {},
      );

      expect(content, isNull);
    });
    test('suppresses technical call envelope even with visible text', () {
      expect(
        resolveBackgroundNotificationContent(
          hasSystemNotification: false,
          data: {
            'title': 'Call ended',
            'envelope': '{"callId":"call-1","eventType":"Ended"}',
          },
        ),
        isNull,
      );
    });

    test('preserves incoming call content', () {
      final content = resolveBackgroundNotificationContent(
        hasSystemNotification: false,
        data: {
          'type': 'incoming',
          'title': 'Incoming call',
          'body': 'Customer',
        },
      );
      expect(content?.title, 'Incoming call');
    });

    test('keeps body-only notifications and ignores malformed envelopes', () {
      final content = resolveBackgroundNotificationContent(
        hasSystemNotification: false,
        data: {'body': 'New order', 'envelope': 'invalid json'},
      );
      expect(content?.title, 'MealMate');
      expect(content?.body, 'New order');
    });

    test('ignores whitespace-only content', () {
      expect(
        resolveBackgroundNotificationContent(
          hasSystemNotification: false,
          data: {'title': '  ', 'body': '  '},
        ),
        isNull,
      );
    });
  });
}
