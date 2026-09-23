import '../models/request/assign_driver_request_dto.dart';
import '../models/response/dispatcher_drivers_roster_response_dto.dart';
import '../models/response/driver_assignment_response_dto.dart';

abstract interface class DispatcherDriversRemoteDataSource {
  Future<DispatcherDriversRosterResponseDto> getRoster({
    required String view,
    String? area,
    String? boxId,
  });

  Future<DriverAssignmentResponseDto> assignDriver({
    required String boxId,
    required AssignDriverRequestDto request,
  });
}
