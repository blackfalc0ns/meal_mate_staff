import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../repo/dispatcher_notifications_repository.dart';

@injectable
class MarkDispatcherNotificationReadUseCase {
  const MarkDispatcherNotificationReadUseCase(this._repository);

  final DispatcherNotificationsRepository _repository;

  Future<ApiResult<void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
