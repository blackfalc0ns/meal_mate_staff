import 'package:injectable/injectable.dart';

import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/errors/api_exception.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../entities/driver_current_location_entity.dart';
import '../repo/driver_details_repository.dart';

@injectable
class GetDriverCurrentLocationUseCase {
  const GetDriverCurrentLocationUseCase(this._repository);

  final DriverDetailsRepository _repository;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<ApiResult<DriverCurrentLocationEntity>> call(String driverId) {
    final trimmedDriverId = driverId.trim();
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

    return _repository.getCurrentLocation(trimmedDriverId);
  }
}
