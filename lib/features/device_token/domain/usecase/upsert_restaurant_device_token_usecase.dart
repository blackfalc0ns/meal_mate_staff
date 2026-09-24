import '../../../../core/network/api_results.dart';
import '../repo/device_token_repository.dart';

class UpsertRestaurantDeviceTokenUseCase {
  const UpsertRestaurantDeviceTokenUseCase(this._repository);

  final DeviceTokenRepository _repository;

  Future<ApiResult<void>> call({
    required String token,
    required String platform,
    required String deviceId,
  }) {
    return _repository.upsertRestaurantToken(
      token: token,
      platform: platform,
      deviceId: deviceId,
    );
  }
}
