import 'package:injectable/injectable.dart';

import '../entities/update_driver_availability_result_entity.dart';
import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class ObserveDriverAvailabilityUpdatesUseCase {
  const ObserveDriverAvailabilityUpdatesUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Stream<UpdateDriverAvailabilityResultEntity> call() {
    return _repository.driverAvailabilityUpdates;
  }
}
