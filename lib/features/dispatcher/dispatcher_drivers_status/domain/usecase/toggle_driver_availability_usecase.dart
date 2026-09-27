import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_results.dart';
import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class ToggleDriverAvailabilityUseCase {
  const ToggleDriverAvailabilityUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Future<ApiResult<bool>> call({
    required String driverId,
    required bool isAvailable,
  }) {
    return _repository.toggleDriverAvailability(driverId, isAvailable);
  }
}
