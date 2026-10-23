import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/delivery_contact_case_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class HoldDeliveryContactCaseUseCase {
  const HoldDeliveryContactCaseUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<DeliveryContactCaseEntity>> call({
    required String tripStopId,
    required String notes,
    required String firstAttemptCallId,
  }) =>
      _repository.holdContactCase(
        tripStopId: tripStopId,
        notes: notes,
        firstAttemptCallId: firstAttemptCallId,
      );
}
