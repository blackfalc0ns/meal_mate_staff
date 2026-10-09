import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/reassignment_request_entity.dart';
import '../entities/reassignment_result_entity.dart';
import '../repo/driver_reassignment_repository.dart';

@injectable
class SubmitDriverReassignmentUseCase {
  const SubmitDriverReassignmentUseCase(this._repository);

  final DriverReassignmentRepository _repository;

  Future<ApiResult<ReassignmentResultEntity>> call({
    required String boxId,
    required ReassignmentRequestEntity request,
  }) {
    return _repository.submit(
      boxId: boxId,
      request: request,
    );
  }
}
