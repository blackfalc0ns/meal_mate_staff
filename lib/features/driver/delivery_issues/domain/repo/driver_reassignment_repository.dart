import '../../../../../core/network/api_results.dart';
import '../entities/reassignment_request_entity.dart';
import '../entities/reassignment_result_entity.dart';

abstract interface class DriverReassignmentRepository {
  Future<ApiResult<ReassignmentResultEntity>> submit({
    required String boxId,
    required ReassignmentRequestEntity request,
  });
}
