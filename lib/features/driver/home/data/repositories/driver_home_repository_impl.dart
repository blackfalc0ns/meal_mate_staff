import '../../domain/entities/driver_active_home_entity.dart';
import '../../domain/entities/driver_start_work_entity.dart';
import '../../domain/repositories/driver_home_repository.dart';
import '../datasources/driver_home_datasource.dart';

class DriverHomeRepositoryImpl implements DriverHomeRepository {
  const DriverHomeRepositoryImpl(this._dataSource);

  final DriverHomeDataSource _dataSource;

  @override
  Future<DriverStartWorkEntity> getStartWorkOverview() {
    return _dataSource.getStartWorkOverview();
  }

  @override
  Future<DriverActiveHomeEntity> getActiveHomeOverview() {
    return _dataSource.getActiveHomeOverview();
  }

  @override
  Future<void> startShift() {
    return _dataSource.startShift();
  }
}
