import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/confirm_driver_pickup_request_entity.dart';
import '../entities/driver_pickup_confirmation_entity.dart';
import '../repo/driver_pickup_repository.dart';

@injectable
class ConfirmDriverBoxPickupUseCase {
  const ConfirmDriverBoxPickupUseCase(this._repository);

  final DriverPickupRepository _repository;

  Future<ApiResult<DriverPickupConfirmationEntity>> call({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  }) {
    return _repository.confirmDriverBoxPickup(
      boxId: boxId,
      idempotencyKey: idempotencyKey,
      request: request,
    );
  }
}
