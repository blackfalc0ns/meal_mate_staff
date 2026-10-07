import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_arrival_request_entity.dart';
import '../entities/driver_arrival_result_entity.dart';
import '../repo/driver_delivery_repository.dart';

@injectable
class ArriveAtDriverCustomerUseCase {
  const ArriveAtDriverCustomerUseCase(this._repository);

  final DriverDeliveryRepository _repository;

  Future<ApiResult<DriverArrivalResultEntity>> call({
    required String boxId,
    required DriverArrivalRequestEntity request,
  }) {
    return _repository.arriveAtCustomer(boxId: boxId, request: request);
  }
}
