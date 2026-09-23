import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';

import '../entities/assign_box_summary_entity.dart';
import '../repo/assign_box_repository.dart';

@injectable
class GetAssignBoxSummaryUseCase {
  const GetAssignBoxSummaryUseCase(this._repository);

  final AssignBoxRepository _repository;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<ApiResult<AssignBoxSummaryEntity>> call(String boxId) {
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

    return _repository.getSummary(trimmedBoxId);
  }
}
