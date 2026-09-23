import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';

import '../entities/dispatcher_drivers_query_entity.dart';
import '../entities/dispatcher_drivers_roster_entity.dart';
import '../repo/dispatcher_drivers_repository.dart';

@injectable
class GetDispatcherDriversRosterUseCase {
  const GetDispatcherDriversRosterUseCase(this._repository);

  final DispatcherDriversRepository _repository;

  Future<ApiResult<DispatcherDriversRosterEntity>> call(
    DispatcherDriversQueryEntity query,
  ) {
    if (query.areaKey != null && query.areaKey!.trim().isEmpty) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Invalid area query parameter.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message: 'Invalid area query parameter.',
            ),
          ),
        ),
      );
    }

    return _repository.getRoster(query);
  }
}
