import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/driver_active_boxes_response_dto.dart';
import '../models/response/driver_current_location_response_dto.dart';
import '../models/response/driver_details_response_dto.dart';
import 'driver_details_remote_data_source.dart';

@LazySingleton(as: DriverDetailsRemoteDataSource)
class DriverDetailsRemoteDataSourceImpl
    implements DriverDetailsRemoteDataSource {
  const DriverDetailsRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverDetailsResponseDto> getDetails(String driverId) {
    return _apiServices.getDispatcherDriverDetails(driverId);
  }

  @override
  Future<DriverActiveBoxesResponseDto> getActiveBoxes(String driverId) {
    return _apiServices.getDispatcherDriverActiveBoxes(driverId);
  }

  @override
  Future<DriverCurrentLocationResponseDto> getCurrentLocation(String driverId) {
    return _apiServices.getDispatcherDriverCurrentLocation(driverId);
  }
}
