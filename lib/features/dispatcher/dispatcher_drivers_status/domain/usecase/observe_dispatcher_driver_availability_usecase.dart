import 'package:injectable/injectable.dart';

import '../entities/update_driver_availability_result_entity.dart';
import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class ObserveDispatcherDriverAvailabilityUseCase {
  const ObserveDispatcherDriverAvailabilityUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Stream<UpdateDriverAvailabilityResultEntity> call(String driverId) {
    return _repository.driverAvailabilityUpdates.where(
      (event) => event.driverId == driverId,
    );
  }
}
