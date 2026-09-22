import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/reassign_driver_request_entity.dart';
import '../entities/reassignment_result_entity.dart';
import '../repo/dispatcher_support_repository.dart';

class ReassignDispatcherIssueUseCase {
  const ReassignDispatcherIssueUseCase(this._repository);

  final DispatcherSupportRepository _repository;

  Future<ApiResult<ReassignmentResultEntity>> call(
    String issueId,
    ReassignDriverRequestEntity request,
  ) {
    return _repository.reassignIssue(issueId.trim(), request);
  }
}
