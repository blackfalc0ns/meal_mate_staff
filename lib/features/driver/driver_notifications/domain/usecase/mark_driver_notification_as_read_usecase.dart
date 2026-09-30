import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../repo/driver_notifications_repository.dart';

@injectable
class MarkDriverNotificationAsReadUseCase {
  const MarkDriverNotificationAsReadUseCase(this._repository);

  final DriverNotificationsRepository _repository;

  Future<ApiResult<void>> call(String notificationId) =>
      _repository.markAsRead(notificationId);
}
