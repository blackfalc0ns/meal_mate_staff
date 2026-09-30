import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/repo/driver_notifications_repository.dart';
import '../data_source/driver_notifications_remote_data_source.dart';
import '../mapper/driver_notification_mapper.dart';

@LazySingleton(as: DriverNotificationsRepository)
class DriverNotificationsRepositoryImpl
    implements DriverNotificationsRepository {
  const DriverNotificationsRepositoryImpl(this._remoteDataSource);

  final DriverNotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<DriverNotificationEntity>>> getNotifications() {
    return safeApiCall<List<DriverNotificationEntity>>(() async {
      final dtoList = await _remoteDataSource.getNotifications();
      return dtoList.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) {
    return safeApiCall<void>(() async {
      await _remoteDataSource.markAsRead(notificationId);
    });
  }
}
