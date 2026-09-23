import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/assign_driver_request_entity.dart';
import '../entities/dispatcher_drivers_query_entity.dart';
import '../entities/dispatcher_drivers_roster_entity.dart';
import '../entities/driver_assignment_result_entity.dart';

abstract interface class DispatcherDriversRepository {
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  );
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  );
}
