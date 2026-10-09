import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_start_delivery_result_entity.dart';
import '../repo/driver_delivery_repository.dart';

@injectable
class StartDriverDeliveryUseCase {
  const StartDriverDeliveryUseCase(this._repository);
  final DriverDeliveryRepository _repository;

  Future<ApiResult<DriverStartDeliveryResultEntity>> call({
    required String boxId,
  }) => _repository.startDelivery(boxId: boxId);
}
