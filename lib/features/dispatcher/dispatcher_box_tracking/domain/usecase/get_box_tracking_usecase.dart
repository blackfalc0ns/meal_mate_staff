import 'package:injectable/injectable.dart';

import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/errors/api_exception.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../entities/box_tracking_entity.dart';
import '../repo/box_tracking_repository.dart';

@injectable
class GetBoxTrackingUseCase {
  const GetBoxTrackingUseCase(this._repository);

  final BoxTrackingRepository _repository;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<ApiResult<BoxTrackingEntity>> call(String boxId) {
    final trimmedBoxId = boxId.trim();
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

    return _repository.getTracking(trimmedBoxId);
  }
}
