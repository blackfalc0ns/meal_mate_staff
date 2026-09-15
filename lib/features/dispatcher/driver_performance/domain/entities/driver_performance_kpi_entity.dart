import 'driver_performance_kpi_type.dart';

class DriverPerformanceKpiEntity {
  const DriverPerformanceKpiEntity({
    required this.id,
    required this.type,
    required this.value,
    required this.subValue,
    this.isHighlighted = false,
  });

  final String id;
  final DriverPerformanceKpiType type;
  final String value;
  final String subValue;
  final bool isHighlighted;
}
