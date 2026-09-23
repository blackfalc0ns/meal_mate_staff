import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import '../entities/operations_page_entity.dart';
import '../entities/operations_query_entity.dart';
import '../repo/operations_log_repository.dart';

@injectable
class GetOperationsLogUseCase {
  const GetOperationsLogUseCase(this._repository);

  final OperationsLogRepository _repository;

  Future<ApiResult<OperationsPageEntity>> call(OperationsQueryEntity query) {
    if (!query.isValid) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage:
                'Invalid operations query: custom date range or page parameters are invalid.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message:
                  'Invalid operations query: custom date range or page parameters are invalid.',
            ),
          ),
        ),
      );
    }

    return _repository.getOperations(query);
  }
}
