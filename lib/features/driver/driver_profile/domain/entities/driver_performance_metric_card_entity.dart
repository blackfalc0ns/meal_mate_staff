import 'driver_performance_chart_point_entity.dart';

class DriverPerformanceMetricCardEntity {
  const DriverPerformanceMetricCardEntity({
    required this.titleKey,
    this.subtitleKey,
    required this.value,
    required this.trendText,
    required this.points,
    this.isAmber = false,
    this.isAreaChart = false,
  });

  final String titleKey;
  final String? subtitleKey;
  final String value;
  final String trendText;
  final List<DriverPerformanceChartPointEntity> points;
  final bool isAmber;
  final bool isAreaChart;
}
