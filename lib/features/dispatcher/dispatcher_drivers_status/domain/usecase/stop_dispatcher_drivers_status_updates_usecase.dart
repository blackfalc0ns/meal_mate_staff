import 'package:injectable/injectable.dart';

import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class StopDispatcherDriversStatusUpdatesUseCase {
  const StopDispatcherDriversStatusUpdatesUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Future<void> call([String ownerId = 'dispatcher-drivers-status']) {
    return _repository.releaseRealtime(ownerId);
  }
}
