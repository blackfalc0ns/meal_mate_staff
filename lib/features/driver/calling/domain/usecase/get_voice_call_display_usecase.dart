import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/voice_call_display_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class GetVoiceCallDisplayUseCase {
  const GetVoiceCallDisplayUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<VoiceCallDisplayEntity>> call(
    String callId, {
    String? languageCode,
  }) {
    return _repository.getCallDisplay(callId, languageCode: languageCode);
  }
}
