import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class LocalNotificationService {
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  });

  Future<void> showNotification({
    required int id,
    required String? title,
    required String? body,
    required String? payload,
  });
}

class FlutterLocalNotificationServiceImpl implements LocalNotificationService {
  FlutterLocalNotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String channelId = 'mealmate_alerts_channel';
  static const String channelName = 'MealMate Alerts';
  static const String channelDescription =
      'High-importance alerts for drivers and dispatchers';

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap(response.payload);
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  @override
  Future<void> showNotification({
    required int id,
    required String? title,
    required String? body,
    required String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(id, title, body, notificationDetails, payload: payload);
  }
}
