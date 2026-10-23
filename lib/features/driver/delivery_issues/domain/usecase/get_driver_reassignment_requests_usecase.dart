import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_reassignment_details_entity.dart';
import '../repo/driver_reassignment_repository.dart';

@injectable
class GetDriverReassignmentRequestsUseCase {
  const GetDriverReassignmentRequestsUseCase(this._repository);

  final DriverReassignmentRepository _repository;

  Future<ApiResult<List<DriverReassignmentDetailsEntity>>> call({
    String? boxId,
    int page = 1,
    int pageSize = 20,
  }) {
    return _repository.getRequests(
      boxId: boxId,
      page: page,
      pageSize: pageSize,
    );
  }
}
