import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/local_notification_service.dart';

class _FakeLocalNotificationService implements LocalNotificationService {
  void Function(String? payload)? tapHandler;
  int? lastId;
  String? lastTitle;
  String? lastBody;
  String? lastPayload;

  @override
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    tapHandler = onNotificationTap;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String? title,
    required String? body,
    required String? payload,
  }) async {
    lastId = id;
    lastTitle = title;
    lastBody = body;
    lastPayload = payload;
  }
}

void main() {
  group('LocalNotificationService contract and constants', () {
    test('channel configuration constants match backend requirements', () {
      expect(
        FlutterLocalNotificationServiceImpl.channelId,
        'mealmate_alerts_channel',
      );
      expect(
        FlutterLocalNotificationServiceImpl.channelName,
        'MealMate Alerts',
      );
    });

    test('fake implementation captures notification show and tap', () async {
      final service = _FakeLocalNotificationService();
      String? tappedPayload;

      await service.initialize(
        onNotificationTap: (payload) => tappedPayload = payload,
      );

      await service.showNotification(
        id: 1,
        title: 'New Order',
        body: 'You have a new delivery',
        payload: '{"boxId":"box-1"}',
      );

      expect(service.lastId, 1);
      expect(service.lastTitle, 'New Order');
      expect(service.lastBody, 'You have a new delivery');
      expect(service.lastPayload, '{"boxId":"box-1"}');

      service.tapHandler?.call('{"boxId":"box-1"}');
      expect(tappedPayload, '{"boxId":"box-1"}');
    });
  });
}
