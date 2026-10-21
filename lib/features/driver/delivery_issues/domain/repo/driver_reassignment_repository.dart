import '../../../../../core/network/api_results.dart';
import '../entities/driver_reassignment_details_entity.dart';
import '../entities/reassignment_request_entity.dart';
import '../entities/reassignment_result_entity.dart';

abstract interface class DriverReassignmentRepository {
  Future<ApiResult<ReassignmentResultEntity>> submit({
    required String boxId,
    required ReassignmentRequestEntity request,
  });

  Future<ApiResult<List<DriverReassignmentDetailsEntity>>> getRequests({
    String? boxId,
    int page = 1,
    int pageSize = 20,
  });

  Future<ApiResult<DriverReassignmentDetailsEntity>> getRequestDetails(
    String requestId,
  );
}
