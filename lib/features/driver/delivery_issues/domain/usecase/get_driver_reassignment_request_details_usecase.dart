import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_reassignment_details_entity.dart';
import '../repo/driver_reassignment_repository.dart';

@injectable
class GetDriverReassignmentRequestDetailsUseCase {
  const GetDriverReassignmentRequestDetailsUseCase(this._repository);

  final DriverReassignmentRepository _repository;

  Future<ApiResult<DriverReassignmentDetailsEntity>> call(String requestId) {
    return _repository.getRequestDetails(requestId);
  }
}
