import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_notification_entity.dart';
import '../repo/dispatcher_notifications_repository.dart';

@injectable
class GetDispatcherNotificationsUseCase {
  const GetDispatcherNotificationsUseCase(this._repository);

  final DispatcherNotificationsRepository _repository;

  Future<ApiResult<List<DispatcherNotificationEntity>>> call() {
    return _repository.getNotifications();
  }
}
