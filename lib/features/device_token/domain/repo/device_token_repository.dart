import '../../../../core/network/api_results.dart';

abstract class DeviceTokenRepository {
  Future<ApiResult<void>> upsertDriverToken({
    required String token,
    required String platform,
    required String deviceId,
    String? registrationId,
  });

  Future<ApiResult<void>> deactivateDriverToken({required String token});

  Future<ApiResult<void>> upsertRestaurantToken({
    required String token,
    required String platform,
    required String deviceId,
  });

  Future<ApiResult<void>> deactivateRestaurantToken({required String token});
}
