import '../../../../core/network/api_results.dart';
import '../repo/device_token_repository.dart';

class DeactivateRestaurantDeviceTokenUseCase {
  const DeactivateRestaurantDeviceTokenUseCase(this._repository);

  final DeviceTokenRepository _repository;

  Future<ApiResult<void>> call({required String token}) {
    return _repository.deactivateRestaurantToken(token: token);
  }
}
