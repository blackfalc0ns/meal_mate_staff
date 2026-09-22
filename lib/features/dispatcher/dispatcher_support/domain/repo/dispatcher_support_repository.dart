import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/dispatcher_issue_detail_entity.dart';
import '../entities/dispatcher_support_query_entity.dart';
import '../entities/dispatcher_support_response_entity.dart';
import '../entities/reassign_driver_candidates_entity.dart';
import '../entities/reassign_driver_request_entity.dart';
import '../entities/reassignment_result_entity.dart';
import '../entities/resolve_issue_result_entity.dart';

abstract class DispatcherSupportRepository {
  Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
    DispatcherSupportQueryEntity query,
  );

  Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(String issueId);

  Future<ApiResult<ResolveIssueResultEntity>> resolveIssue(
    String issueId,
    String resolutionNotes,
  );

  Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<ApiResult<ReassignmentResultEntity>> reassignIssue(
    String issueId,
    ReassignDriverRequestEntity request,
  );
}
