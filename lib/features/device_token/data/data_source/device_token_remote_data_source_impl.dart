import '../../../../core/network/api_services.dart';
import '../models/request/driver_device_token_request_dto.dart';
import '../models/request/restaurant_device_token_request_dto.dart';
import 'device_token_remote_data_source.dart';

class DeviceTokenRemoteDataSourceImpl implements DeviceTokenRemoteDataSource {
  DeviceTokenRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<void> upsertDriverToken(DriverDeviceTokenRequestDto request) =>
      _apiServices.upsertDriverDeviceToken(request);

  @override
  Future<void> deactivateDriverToken(String token) =>
      _apiServices.deactivateDriverDeviceToken(token);

  @override
  Future<void> upsertRestaurantToken(RestaurantDeviceTokenRequestDto request) =>
      _apiServices.upsertRestaurantDeviceTokens(request);

  @override
  Future<void> deactivateRestaurantToken(String token) =>
      _apiServices.deactivateRestaurantDeviceTokens(token);
}
