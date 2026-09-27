import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/update_driver_availability_request_entity.dart';
import '../entities/update_driver_availability_result_entity.dart';
import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class ToggleDriverAvailabilityUseCase {
  const ToggleDriverAvailabilityUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Future<ApiResult<UpdateDriverAvailabilityResultEntity>> call({
    UpdateDriverAvailabilityRequestEntity? request,
    String? driverId,
    bool? isAvailable,
    String? reason,
  }) {
    final effectiveRequest =
        request ??
        UpdateDriverAvailabilityRequestEntity(
          driverId: driverId ?? '',
          isAvailable: isAvailable ?? false,
          reason: reason,
        );
    return _repository.toggleDriverAvailability(effectiveRequest);
  }
}
