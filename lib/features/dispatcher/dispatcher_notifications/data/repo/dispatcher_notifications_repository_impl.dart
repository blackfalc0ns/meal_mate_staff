import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import '../../domain/repo/dispatcher_notifications_repository.dart';
import '../data_source/dispatcher_notifications_remote_data_source.dart';
import '../mapper/dispatcher_notification_mapper.dart';

@Injectable(as: DispatcherNotificationsRepository)
class DispatcherNotificationsRepositoryImpl
    implements DispatcherNotificationsRepository {
  const DispatcherNotificationsRepositoryImpl(this._remoteDataSource);

  final DispatcherNotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<DispatcherNotificationEntity>>> getNotifications() {
    return safeApiCall(() async {
      final dtos = await _remoteDataSource.getNotifications();
      return dtos.map(DispatcherNotificationMapper.toEntity).toList();
    });
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) {
    return safeApiCall(() => _remoteDataSource.markAsRead(notificationId));
  }
}
