import '../../../../core/network/api_results.dart';
import '../../domain/repo/device_token_repository.dart';
import '../data_source/device_token_remote_data_source.dart';
import '../models/request/driver_device_token_request_dto.dart';
import '../models/request/restaurant_device_token_request_dto.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  DeviceTokenRepositoryImpl(this._remoteDataSource);

  final DeviceTokenRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<void>> upsertDriverToken({
    required String token,
    required String platform,
    required String deviceId,
    String? registrationId,
  }) {
    return safeApiCall<void>(
      () => _remoteDataSource.upsertDriverToken(
        DriverDeviceTokenRequestDto(
          token: token,
          platform: platform,
          deviceId: deviceId,
          registrationId: registrationId,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<void>> deactivateDriverToken({required String token}) {
    return safeApiCall<void>(
      () => _remoteDataSource.deactivateDriverToken(token),
    );
  }

  @override
  Future<ApiResult<void>> upsertRestaurantToken({
    required String token,
    required String platform,
    required String deviceId,
  }) {
    return safeApiCall<void>(
      () => _remoteDataSource.upsertRestaurantToken(
        RestaurantDeviceTokenRequestDto(
          token: token,
          platform: platform,
          deviceId: deviceId,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<void>> deactivateRestaurantToken({required String token}) {
    return safeApiCall<void>(
      () => _remoteDataSource.deactivateRestaurantToken(token),
    );
  }
}
