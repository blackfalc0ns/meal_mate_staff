import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';
import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../../domain/entities/dispatcher_support_response_entity.dart';
import '../../domain/entities/reassign_driver_candidates_entity.dart';
import '../../domain/entities/reassign_driver_request_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../../domain/entities/resolve_issue_result_entity.dart';
import '../../domain/repo/dispatcher_support_repository.dart';
import '../data_source/dispatcher_support_remote_data_source.dart';
import '../mapper/dispatcher_issue_details_mapper.dart';
import '../mapper/dispatcher_reassignment_mapper.dart';
import '../mapper/dispatcher_support_mapper.dart';
import '../models/request/resolve_issue_request_dto.dart';

@LazySingleton(as: DispatcherSupportRepository)
class DispatcherSupportRepositoryImpl implements DispatcherSupportRepository {
  const DispatcherSupportRepositoryImpl(this._remoteDataSource);

  final DispatcherSupportRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
    DispatcherSupportQueryEntity query,
  ) {
    return safeApiCall(() async {
      final responseDto = await _remoteDataSource.getIssues(query);
      return responseDto.toEntity();
    });
  }

  @override
  Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(
    String issueId,
  ) {
    return safeApiCall(() async {
      final responseDto = await _remoteDataSource.getIssueDetails(issueId);
      return responseDto.toEntity();
    });
  }

  @override
  Future<ApiResult<ResolveIssueResultEntity>> resolveIssue(
    String issueId,
    String resolutionNotes,
  ) {
    return safeApiCall(() async {
      final trimmedNotes = resolutionNotes.trim();
      final requestDto = ResolveIssueRequestDto(
        resolutionNotes: trimmedNotes,
      );
      final responseDto = await _remoteDataSource.resolveIssue(
        issueId,
        requestDto,
      );
      return responseDto.toEntity();
    });
  }

  @override
  Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return safeApiCall(() async {
      final responseDto = await _remoteDataSource.getReplacementCandidates(
        issueId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return responseDto.toEntity();
    });
  }

  @override
  Future<ApiResult<ReassignmentResultEntity>> reassignIssue(
    String issueId,
    ReassignDriverRequestEntity request,
  ) {
    return safeApiCall(() async {
      final responseDto = await _remoteDataSource.reassignIssue(
        issueId,
        request.toDto(),
      );
      return responseDto.toEntity();
    });
  }
}
