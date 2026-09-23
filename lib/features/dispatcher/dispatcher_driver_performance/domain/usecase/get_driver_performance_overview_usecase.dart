import 'package:injectable/injectable.dart';

import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/errors/api_exception.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../entities/driver_performance_overview_entity.dart';
import '../entities/driver_performance_query_entity.dart';
import '../repo/driver_performance_repository.dart';

@injectable
class GetDriverPerformanceOverviewUseCase {
  const GetDriverPerformanceOverviewUseCase(this._repository);

  final DriverPerformanceRepository _repository;

  Future<ApiResult<DriverPerformanceOverviewEntity>> call(
    DriverPerformanceQueryEntity query,
  ) async {
    if (!query.isValid) {
      return ApiErrorResult(
        failure: Failure.fromException(
          const ApiException(
            errorType: ApiErrorType.validationError,
            message: 'Invalid custom date range',
          ),
        ),
      );
    }
    return _repository.getOverview(query);
  }
}
