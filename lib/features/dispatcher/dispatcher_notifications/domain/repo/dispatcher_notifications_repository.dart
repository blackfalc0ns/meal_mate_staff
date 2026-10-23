import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_notification_entity.dart';

abstract class DispatcherNotificationsRepository {
  Future<ApiResult<List<DispatcherNotificationEntity>>> getNotifications();
  Future<ApiResult<void>> markAsRead(String notificationId);
}
