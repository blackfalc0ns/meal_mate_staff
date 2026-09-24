import '../../../../core/network/api_results.dart';
import '../repo/device_token_repository.dart';

class UpsertDriverDeviceTokenUseCase {
  const UpsertDriverDeviceTokenUseCase(this._repository);

  final DeviceTokenRepository _repository;

  Future<ApiResult<void>> call({
    required String token,
    required String platform,
    required String deviceId,
    String? registrationId,
  }) {
    return _repository.upsertDriverToken(
      token: token,
      platform: platform,
      deviceId: deviceId,
      registrationId: registrationId,
    );
  }
}
