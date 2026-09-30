import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_notification_entity.dart';
import '../repo/driver_notifications_repository.dart';

@injectable
class GetDriverNotificationsUseCase {
  const GetDriverNotificationsUseCase(this._repository);

  final DriverNotificationsRepository _repository;

  Future<ApiResult<List<DriverNotificationEntity>>> call() =>
      _repository.getNotifications();
}
