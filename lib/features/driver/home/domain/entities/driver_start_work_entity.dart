import 'driver_start_work_metric_entity.dart';
import 'driver_start_work_requirement_entity.dart';

class DriverStartWorkEntity {
  const DriverStartWorkEntity({
    required this.isAvailable,
    required this.statusLabel,
    required this.statusDescription,
    required this.metrics,
    required this.requirements,
  });

  final bool isAvailable;
  final String statusLabel;
  final String statusDescription;
  final List<DriverStartWorkMetricEntity> metrics;
  final List<DriverStartWorkRequirementEntity> requirements;
}
