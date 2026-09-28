import '../entities/driver_active_home_entity.dart';
import '../entities/driver_start_work_entity.dart';

abstract class DriverHomeRepository {
  Future<DriverStartWorkEntity> getStartWorkOverview();
  Future<DriverActiveHomeEntity> getActiveHomeOverview();
  Future<void> startShift();
}
