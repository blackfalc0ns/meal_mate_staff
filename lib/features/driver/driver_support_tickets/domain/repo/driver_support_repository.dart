import '../../../../../core/network/api_results.dart';
import '../entities/driver_support_add_photos_result_entity.dart';
import '../entities/driver_support_issues_page_entity.dart';
import '../entities/driver_support_issues_query_entity.dart';
import '../entities/driver_support_ticket_details_entity.dart';

abstract interface class DriverSupportRepository {
  Future<ApiResult<DriverSupportIssuesPageEntity>> getSupportIssues(
    DriverSupportIssuesQueryEntity query,
  );

  Future<ApiResult<DriverSupportTicketDetailsEntity>> getSupportIssueDetails(
    String issueId,
  );

  Future<ApiResult<DriverSupportAddPhotosResultEntity>> addSupportIssuePhotos(
    String issueId,
    List<String> storageKeys,
  );
}
