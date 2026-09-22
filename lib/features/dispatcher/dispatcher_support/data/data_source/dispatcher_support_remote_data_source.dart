import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../models/request/reassign_driver_request_dto.dart';
import '../models/request/resolve_issue_request_dto.dart';
import '../models/response/dispatcher_issue_details_response_dto.dart';
import '../models/response/dispatcher_support_response_dto.dart';
import '../models/response/reassign_driver_candidates_response_dto.dart';
import '../models/response/reassignment_response_dto.dart';
import '../models/response/resolve_issue_response_dto.dart';

abstract class DispatcherSupportRemoteDataSource {
  Future<DispatcherSupportResponseDto> getIssues(
    DispatcherSupportQueryEntity query,
  );

  Future<DispatcherIssueDetailsResponseDto> getIssueDetails(String issueId);

  Future<ResolveIssueResponseDto> resolveIssue(
    String issueId,
    ResolveIssueRequestDto request,
  );

  Future<ReassignDriverCandidatesResponseDto> getReplacementCandidates(
    String issueId, {
    required int pageNumber,
    required int pageSize,
  });

  Future<ReassignmentResponseDto> reassignIssue(
    String issueId,
    ReassignDriverRequestDto request,
  );
}
