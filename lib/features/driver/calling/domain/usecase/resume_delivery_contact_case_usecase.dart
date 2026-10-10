import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/delivery_contact_case_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class ResumeDeliveryContactCaseUseCase {
  const ResumeDeliveryContactCaseUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<DeliveryContactCaseEntity>> call({
    required String tripStopId,
    double? lat,
    double? lng,
  }) =>
      _repository.resumeContactCase(
        tripStopId: tripStopId,
        lat: lat,
        lng: lng,
      );
}
