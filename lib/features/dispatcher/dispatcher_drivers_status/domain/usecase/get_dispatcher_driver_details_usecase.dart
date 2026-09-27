import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../entities/dispatcher_driver_details_entity.dart';
import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class GetDispatcherDriverDetailsUseCase {
  const GetDispatcherDriverDetailsUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Future<ApiResult<DispatcherDriverDetailsEntity>> call(String driverId) {
    if (driverId.trim().isEmpty) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Driver ID cannot be empty',
            code: 'validation',
          ),
        ),
      );
    }
    return _repository.getDriverDetails(driverId);
  }
}
