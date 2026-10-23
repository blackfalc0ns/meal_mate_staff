import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/driver_support_add_photos_request_dto.dart';
import '../models/response/driver_support_add_photos_response_dto.dart';
import '../models/response/driver_support_issue_details_response_dto.dart';
import '../models/response/driver_support_issues_response_dto.dart';
import 'driver_support_remote_data_source.dart';

@Injectable(as: DriverSupportRemoteDataSource)
class DriverSupportRemoteDataSourceImpl
    implements DriverSupportRemoteDataSource {
  const DriverSupportRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverSupportIssuesResponseDto> getIssues({
    String? status,
    String? search,
    int? pageNumber,
    int? pageSize,
  }) {
    return _apiServices.getDriverSupportIssues(
      status: status,
      search: search,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<DriverSupportIssueDetailsResponseDto> getIssueDetails(String issueId) {
    return _apiServices.getDriverSupportIssueDetails(issueId);
  }

  @override
  Future<DriverSupportAddPhotosResponseDto> addPhotos(
    String issueId,
    DriverSupportAddPhotosRequestDto request,
  ) {
    return _apiServices.addDriverSupportIssuePhotos(issueId, request);
  }
}
