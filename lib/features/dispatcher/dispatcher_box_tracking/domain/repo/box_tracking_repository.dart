import '../../../../../core/network/api_results.dart';
import '../entities/box_tracking_entity.dart';
import '../entities/report_box_issue_request_entity.dart';
import '../entities/report_box_issue_result_entity.dart';

abstract interface class BoxTrackingRepository {
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId);
  Future<ApiResult<ReportBoxIssueResultEntity>> reportIssue(
    String boxId,
    ReportBoxIssueRequestEntity request,
  );
}
