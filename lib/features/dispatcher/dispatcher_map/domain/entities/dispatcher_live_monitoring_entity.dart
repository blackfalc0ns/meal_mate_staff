import 'dispatcher_map_driver_entity.dart';
import 'dispatcher_map_kpi_entity.dart';

class DispatcherLiveMonitoringEntity {
  const DispatcherLiveMonitoringEntity({
    required this.kpi,
    required this.drivers,
  });

  final DispatcherMapKpiEntity kpi;
  final List<DispatcherMapDriverEntity> drivers;
}
