import '../models/driver_notification_dto.dart';

abstract class DriverNotificationsRemoteDataSource {
  Future<List<DriverNotificationDto>> getNotifications();
  Future<void> markAsRead(String notificationId);
}
