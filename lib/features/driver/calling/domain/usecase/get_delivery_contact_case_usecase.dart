import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/delivery_contact_case_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class GetDeliveryContactCaseUseCase {
  const GetDeliveryContactCaseUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<DeliveryContactCaseEntity>> call(String tripStopId) =>
      _repository.getContactCase(tripStopId);
}
