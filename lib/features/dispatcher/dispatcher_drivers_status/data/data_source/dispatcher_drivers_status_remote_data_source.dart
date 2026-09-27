import '../models/request/update_driver_availability_request_dto.dart';
import '../models/response/dispatcher_driver_details_response_dto.dart';
import '../models/response/dispatcher_drivers_status_response_dto.dart';
import '../models/response/update_driver_availability_response_dto.dart';

abstract interface class DispatcherDriversStatusRemoteDataSource {
  Future<DispatcherDriversStatusResponseDto> getDriversStatus({
    String? search,
    String status = 'All',
    String sortBy = 'Name',
    int pageNumber = 1,
    int pageSize = 15,
  });

  Future<UpdateDriverAvailabilityResponseDto> updateDriverAvailability(
    String driverId,
    UpdateDriverAvailabilityRequestDto request,
  );

  Future<DispatcherDriverDetailsResponseDto> getDriverDetails(String driverId);
}
