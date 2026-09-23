import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/assign_driver_request_dto.dart';
import '../models/response/dispatcher_drivers_roster_response_dto.dart';
import '../models/response/driver_assignment_response_dto.dart';
import 'dispatcher_drivers_remote_data_source.dart';

@LazySingleton(as: DispatcherDriversRemoteDataSource)
class DispatcherDriversRemoteDataSourceImpl
    implements DispatcherDriversRemoteDataSource {
  const DispatcherDriversRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DispatcherDriversRosterResponseDto> getRoster({
    required String view,
    String? area,
    String? boxId,
  }) {
    return _apiServices.getDispatcherDriversRoster(
      view: view,
      area: area,
      boxId: boxId,
    );
  }

  @override
  Future<DriverAssignmentResponseDto> assignDriver({
    required String boxId,
    required AssignDriverRequestDto request,
  }) {
    return _apiServices.assignDriverToBox(boxId, request);
  }
}
