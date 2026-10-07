import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_deliver_request_entity.dart';
import '../entities/driver_deliver_result_entity.dart';
import '../repo/driver_delivery_repository.dart';

@injectable
class DeliverDriverOrderUseCase {
  const DeliverDriverOrderUseCase(this._repository);

  final DriverDeliveryRepository _repository;

  Future<ApiResult<DriverDeliverResultEntity>> call({
    required String boxId,
    required DriverDeliverRequestEntity request,
  }) {
    return _repository.deliverOrder(boxId: boxId, request: request);
  }
}
