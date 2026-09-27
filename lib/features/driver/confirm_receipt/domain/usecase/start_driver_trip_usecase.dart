import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_trip_start_entity.dart';
import '../entities/start_driver_trip_request_entity.dart';
import '../repo/driver_pickup_repository.dart';

@injectable
class StartDriverTripUseCase {
  const StartDriverTripUseCase(this._repository);

  final DriverPickupRepository _repository;

  Future<ApiResult<DriverTripStartEntity>> call({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestEntity request,
  }) {
    return _repository.startDriverTrip(
      tripId: tripId,
      idempotencyKey: idempotencyKey,
      request: request,
    );
  }
}
