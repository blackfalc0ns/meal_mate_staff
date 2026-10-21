import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/delivery_manager_notification_response_dto.dart';
import 'dispatcher_notifications_remote_data_source.dart';

@Injectable(as: DispatcherNotificationsRemoteDataSource)
class DispatcherNotificationsRemoteDataSourceImpl
    implements DispatcherNotificationsRemoteDataSource {
  DispatcherNotificationsRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<List<DeliveryManagerNotificationResponseDto>> getNotifications() {
    return _apiServices.getDeliveryManagerNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _apiServices.markDeliveryManagerNotificationAsRead(notificationId);
  }
}
