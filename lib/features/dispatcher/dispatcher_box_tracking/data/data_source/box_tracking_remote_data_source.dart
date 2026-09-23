import '../models/request/report_box_issue_request_dto.dart';
import '../models/response/box_tracking_response_dto.dart';
import '../models/response/report_box_issue_response_dto.dart';

abstract interface class BoxTrackingRemoteDataSource {
  Future<BoxTrackingResponseDto> getTracking(String boxId);
  Future<ReportBoxIssueResponseDto> reportIssue(
    String boxId,
    ReportBoxIssueRequestDto request,
  );
}
