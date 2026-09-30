import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_notification_entity.dart';

abstract class DriverNotificationsRepository {
  Future<ApiResult<List<DriverNotificationEntity>>> getNotifications();
  Future<ApiResult<void>> markAsRead(String notificationId);
}
