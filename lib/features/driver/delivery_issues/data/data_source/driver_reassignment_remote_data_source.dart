import '../models/request/driver_reassignment_request_dto.dart';
import '../models/response/driver_reassignment_request_details_dto.dart';
import '../models/response/driver_reassignment_response_dto.dart';

abstract interface class DriverReassignmentRemoteDataSource {
  Future<DriverReassignmentResponseDto> submit({
    required String boxId,
    required DriverReassignmentRequestDto request,
  });

  Future<List<DriverReassignmentRequestDetailsDto>> getRequests({
    String? boxId,
    int page = 1,
    int pageSize = 20,
  });

  Future<DriverReassignmentRequestDetailsDto> getRequestDetails(
    String requestId,
  );
}
