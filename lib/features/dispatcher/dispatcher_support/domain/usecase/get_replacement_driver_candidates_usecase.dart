import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import '../entities/reassign_driver_candidates_entity.dart';
import '../repo/dispatcher_support_repository.dart';

class GetReplacementDriverCandidatesUseCase {
  const GetReplacementDriverCandidatesUseCase(this._repository);

  final DispatcherSupportRepository _repository;

  Future<ApiResult<ReassignDriverCandidatesEntity>> call(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    if (pageNumber < 1) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(errorMessage: 'Invalid pageNumber: must be >= 1'),
        ),
      );
    }
    if (pageSize < 1 || pageSize > 50) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(errorMessage: 'Invalid pageSize: must be between 1 and 50'),
        ),
      );
    }
    return _repository.getReplacementCandidates(
      issueId.trim(),
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
