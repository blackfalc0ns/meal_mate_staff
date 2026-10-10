import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/phone_grant_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class RevealCustomerPhoneUseCase {
  const RevealCustomerPhoneUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<PhoneGrantEntity>> call({
    required String tripStopId,
    required String clientRequestId,
    required String reason,
  }) =>
      _repository.revealPhone(
        tripStopId: tripStopId,
        clientRequestId: clientRequestId,
        reason: reason,
      );
}
