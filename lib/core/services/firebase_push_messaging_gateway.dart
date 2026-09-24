import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_messaging_gateway.dart';

class FirebasePushMessagingGateway implements PushMessagingGateway {
  FirebasePushMessagingGateway({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return _mapStatus(settings.authorizationStatus);
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return _mapStatus(settings.authorizationStatus);
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushNotificationMessage> get onMessageReceived =>
      FirebaseMessaging.onMessage.map(_mapMessage);

  @override
  Stream<PushNotificationMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_mapMessage);

  @override
  Future<PushNotificationMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message != null ? _mapMessage(message) : null;
  }

  NotificationPermissionStatus _mapStatus(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional =>
        NotificationPermissionStatus.authorized,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionStatus.notDetermined,
      _ => NotificationPermissionStatus.denied,
    };
  }

  PushNotificationMessage _mapMessage(RemoteMessage message) {
    return PushNotificationMessage(
      messageId: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
