import 'package:injectable/injectable.dart';

import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class StartDispatcherDriversStatusUpdatesUseCase {
  const StartDispatcherDriversStatusUpdatesUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Future<void> call([String ownerId = 'dispatcher-drivers-status']) {
    return _repository.acquireRealtime(ownerId);
  }
}
