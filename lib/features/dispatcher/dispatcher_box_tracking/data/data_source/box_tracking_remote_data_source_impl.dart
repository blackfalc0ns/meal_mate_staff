import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/report_box_issue_request_dto.dart';
import '../models/response/box_tracking_response_dto.dart';
import '../models/response/report_box_issue_response_dto.dart';
import 'box_tracking_remote_data_source.dart';

@LazySingleton(as: BoxTrackingRemoteDataSource)
class BoxTrackingRemoteDataSourceImpl implements BoxTrackingRemoteDataSource {
  const BoxTrackingRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<BoxTrackingResponseDto> getTracking(String boxId) {
    return _apiServices.getBoxTracking(boxId);
  }

  @override
  Future<ReportBoxIssueResponseDto> reportIssue(
    String boxId,
    ReportBoxIssueRequestDto request,
  ) {
    return _apiServices.reportBoxIssue(boxId, request);
  }
}
