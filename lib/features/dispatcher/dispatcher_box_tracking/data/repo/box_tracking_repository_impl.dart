import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/box_tracking_entity.dart';
import '../../domain/entities/report_box_issue_request_entity.dart';
import '../../domain/entities/report_box_issue_result_entity.dart';
import '../../domain/repo/box_tracking_repository.dart';
import '../data_source/box_tracking_remote_data_source.dart';
import '../mapper/box_tracking_mapper.dart';

@LazySingleton(as: BoxTrackingRepository)
class BoxTrackingRepositoryImpl implements BoxTrackingRepository {
  const BoxTrackingRepositoryImpl(this._remoteDataSource);

  final BoxTrackingRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getTracking(boxId);
      return response.toEntity();
    });
  }

  @override
  Future<ApiResult<ReportBoxIssueResultEntity>> reportIssue(
    String boxId,
    ReportBoxIssueRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.reportIssue(
        boxId,
        request.toDto(),
      );
      return response.toEntity();
    });
  }
}
