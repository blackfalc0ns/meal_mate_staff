import '../models/response/delivery_manager_notification_response_dto.dart';

abstract class DispatcherNotificationsRemoteDataSource {
  Future<List<DeliveryManagerNotificationResponseDto>> getNotifications();
  Future<void> markAsRead(String notificationId);
}
