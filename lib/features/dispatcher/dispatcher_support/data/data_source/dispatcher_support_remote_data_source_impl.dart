import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../models/request/reassign_driver_request_dto.dart';
import '../models/request/resolve_issue_request_dto.dart';
import '../models/response/dispatcher_issue_details_response_dto.dart';
import '../models/response/dispatcher_support_response_dto.dart';
import '../models/response/reassign_driver_candidates_response_dto.dart';
import '../models/response/reassignment_response_dto.dart';
import '../models/response/resolve_issue_response_dto.dart';
import 'dispatcher_support_remote_data_source.dart';

@LazySingleton(as: DispatcherSupportRemoteDataSource)
class DispatcherSupportRemoteDataSourceImpl
    implements DispatcherSupportRemoteDataSource {
  const DispatcherSupportRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DispatcherSupportResponseDto> getIssues(
    DispatcherSupportQueryEntity query,
  ) {
    return _apiServices.getDispatcherSupportIssues(
      area: query.area,
      status: query.apiStatus,
      search: query.search.trim().isEmpty ? null : query.search.trim(),
      datePreset: query.apiDatePreset,
      fromDateUtc: query.fromDateUtc?.toUtc().toIso8601String(),
      toDateUtc: query.toDateUtc?.toUtc().toIso8601String(),
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
    );
  }

  @override
  Future<DispatcherIssueDetailsResponseDto> getIssueDetails(String issueId) {
    return _apiServices.getDispatcherIssueDetails(issueId);
  }

  @override
  Future<ResolveIssueResponseDto> resolveIssue(
    String issueId,
    ResolveIssueRequestDto request,
  ) {
    return _apiServices.resolveDispatcherIssue(issueId, request);
  }

  @override
  Future<ReassignDriverCandidatesResponseDto> getReplacementCandidates(
    String issueId, {
    required int pageNumber,
    required int pageSize,
  }) {
    return _apiServices.getReplacementDriverCandidates(
      issueId,
      pageNumber,
      pageSize,
    );
  }

  @override
  Future<ReassignmentResponseDto> reassignIssue(
    String issueId,
    ReassignDriverRequestDto request,
  ) {
    return _apiServices.reassignDispatcherIssue(issueId, request);
  }
}
