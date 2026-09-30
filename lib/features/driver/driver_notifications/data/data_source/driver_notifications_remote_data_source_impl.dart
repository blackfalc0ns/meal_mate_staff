import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/driver_notification_dto.dart';
import 'driver_notifications_remote_data_source.dart';

@LazySingleton(as: DriverNotificationsRemoteDataSource)
class DriverNotificationsRemoteDataSourceImpl
    implements DriverNotificationsRemoteDataSource {
  const DriverNotificationsRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<List<DriverNotificationDto>> getNotifications() =>
      _apiServices.getDriverNotifications();

  @override
  Future<void> markAsRead(String notificationId) =>
      _apiServices.markDriverNotificationAsRead(notificationId);
}
