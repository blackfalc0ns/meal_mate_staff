import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/voice_device_session_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class RegisterVoiceDeviceUseCase {
  const RegisterVoiceDeviceUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<VoiceDeviceSessionEntity>> call({
    required String fcmDeviceTokenId,
    required String platform,
    required String deviceId,
    int capabilityVersion = 2,
  }) =>
      _repository.registerVoiceDevice(
        fcmDeviceTokenId: fcmDeviceTokenId,
        platform: platform,
        deviceId: deviceId,
        capabilityVersion: capabilityVersion,
      );
}
