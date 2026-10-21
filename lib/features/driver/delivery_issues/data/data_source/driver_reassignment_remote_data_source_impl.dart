import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/driver_reassignment_request_dto.dart';
import '../models/response/driver_reassignment_request_details_dto.dart';
import '../models/response/driver_reassignment_response_dto.dart';
import 'driver_reassignment_remote_data_source.dart';

@Injectable(as: DriverReassignmentRemoteDataSource)
class DriverReassignmentRemoteDataSourceImpl
    implements DriverReassignmentRemoteDataSource {
  const DriverReassignmentRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverReassignmentResponseDto> submit({
    required String boxId,
    required DriverReassignmentRequestDto request,
  }) {
    return _apiServices.requestDriverReassignment(boxId, request);
  }

  @override
  Future<List<DriverReassignmentRequestDetailsDto>> getRequests({
    String? boxId,
    int page = 1,
    int pageSize = 20,
  }) {
    return _apiServices.getDriverReassignmentRequests(
      boxId: boxId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<DriverReassignmentRequestDetailsDto> getRequestDetails(
    String requestId,
  ) {
    return _apiServices.getDriverReassignmentRequestById(requestId);
  }
}
