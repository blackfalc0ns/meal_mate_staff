enum NotificationPermissionStatus {
  authorized,
  denied,
  notDetermined;

  bool get isAuthorized => this == NotificationPermissionStatus.authorized;
}

class PushNotificationMessage {
  const PushNotificationMessage({
    this.messageId,
    this.title,
    this.body,
    this.data = const {},
  });

  final String? messageId;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
}

abstract class PushMessagingGateway {
  Future<NotificationPermissionStatus> requestPermission();
  Future<NotificationPermissionStatus> getPermissionStatus();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Stream<PushNotificationMessage> get onMessageReceived;
  Stream<PushNotificationMessage> get onMessageOpenedApp;
  Future<PushNotificationMessage?> getInitialMessage();
}

class NoOpPushMessagingGateway implements PushMessagingGateway {
  const NoOpPushMessagingGateway();

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<PushNotificationMessage> get onMessageReceived => const Stream.empty();

  @override
  Stream<PushNotificationMessage> get onMessageOpenedApp =>
      const Stream.empty();

  @override
  Future<String?> getToken() async => null;

  @override
  Future<PushNotificationMessage?> getInitialMessage() async => null;

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.notDetermined;

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async =>
      NotificationPermissionStatus.notDetermined;
}
