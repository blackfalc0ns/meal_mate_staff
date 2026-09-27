import '../models/response/dispatcher_drivers_status_response_dto.dart';

abstract interface class DispatcherDriversStatusRemoteDataSource {
  Future<DispatcherDriversStatusResponseDto> getDriversStatus();
  Future<bool> toggleDriverAvailability(String driverId, bool isAvailable);
}
