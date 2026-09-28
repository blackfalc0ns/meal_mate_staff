import '../../domain/entities/driver_active_home_entity.dart';
import '../../domain/entities/driver_start_work_entity.dart';

abstract class DriverHomeDataSource {
  Future<DriverStartWorkEntity> getStartWorkOverview();
  Future<DriverActiveHomeEntity> getActiveHomeOverview();
  Future<void> startShift();
}
