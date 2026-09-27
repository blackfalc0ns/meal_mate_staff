import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_pickup_summary_entity.dart';
import '../repo/driver_pickup_repository.dart';

@injectable
class GetDriverPickupSummaryUseCase {
  const GetDriverPickupSummaryUseCase(this._repository);

  final DriverPickupRepository _repository;

  Future<ApiResult<DriverPickupSummaryEntity>> call(String tripId) {
    return _repository.getDriverPickupSummary(tripId);
  }
}
