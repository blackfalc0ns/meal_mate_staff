import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';

import '../entities/assign_driver_request_entity.dart';
import '../entities/driver_assignment_result_entity.dart';
import '../repo/dispatcher_drivers_repository.dart';

@injectable
class AssignDriverToBoxUseCase {
  const AssignDriverToBoxUseCase(this._repository);

  final DispatcherDriversRepository _repository;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static const int maxNotesLength = 500;

  Future<ApiResult<DriverAssignmentResultEntity>> call(
    AssignDriverRequestEntity request,
  ) {
    final trimmedBoxId = request.boxId.trim();
    if (trimmedBoxId.isEmpty || !_guidRegex.hasMatch(trimmedBoxId)) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Invalid box ID: must be a valid GUID.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message: 'Invalid box ID: must be a valid GUID.',
            ),
          ),
        ),
      );
    }

    final trimmedDriverId = request.driverId.trim();
    if (trimmedDriverId.isEmpty || !_guidRegex.hasMatch(trimmedDriverId)) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Invalid driver ID: must be a valid GUID.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message: 'Invalid driver ID: must be a valid GUID.',
            ),
          ),
        ),
      );
    }

    if (request.notes.length > maxNotesLength) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage:
                'Notes exceed maximum allowed length of $maxNotesLength characters.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message: 'Notes exceed maximum allowed length.',
            ),
          ),
        ),
      );
    }

    return _repository.assignDriver(request);
  }
}
