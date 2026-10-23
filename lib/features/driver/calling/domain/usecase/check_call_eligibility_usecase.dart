import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/voice_call_eligibility_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class CheckCallEligibilityUseCase {
  const CheckCallEligibilityUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<VoiceCallEligibilityEntity>> call(String tripStopId) =>
      _repository.checkEligibility(tripStopId);
}
