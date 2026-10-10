import '../models/request/driver_device_token_request_dto.dart';
import '../models/request/restaurant_device_token_request_dto.dart';
import '../models/response/driver_device_token_response_dto.dart';

abstract class DeviceTokenRemoteDataSource {
  Future<DriverDeviceTokenResponseDto?> upsertDriverToken(
    DriverDeviceTokenRequestDto request,
  );
  Future<void> deactivateDriverToken(String token);
  Future<void> upsertRestaurantToken(RestaurantDeviceTokenRequestDto request);
  Future<void> deactivateRestaurantToken(String token);
}
