import '../models/request/driver_support_add_photos_request_dto.dart';
import '../models/response/driver_support_add_photos_response_dto.dart';
import '../models/response/driver_support_issue_details_response_dto.dart';
import '../models/response/driver_support_issues_response_dto.dart';

abstract interface class DriverSupportRemoteDataSource {
  Future<DriverSupportIssuesResponseDto> getIssues({
    String? status,
    String? search,
    int? pageNumber,
    int? pageSize,
  });

  Future<DriverSupportIssueDetailsResponseDto> getIssueDetails(String issueId);

  Future<DriverSupportAddPhotosResponseDto> addPhotos(
    String issueId,
    DriverSupportAddPhotosRequestDto request,
  );
}
