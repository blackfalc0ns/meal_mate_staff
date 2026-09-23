import '../models/response/driver_active_boxes_response_dto.dart';
import '../models/response/driver_current_location_response_dto.dart';
import '../models/response/driver_details_response_dto.dart';

abstract interface class DriverDetailsRemoteDataSource {
  Future<DriverDetailsResponseDto> getDetails(String driverId);
  Future<DriverActiveBoxesResponseDto> getActiveBoxes(String driverId);
  Future<DriverCurrentLocationResponseDto> getCurrentLocation(String driverId);
}
