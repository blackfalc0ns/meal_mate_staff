import 'driver_performance_kpi_entity.dart';
import 'driver_performance_kpi_type.dart';

class DriverPerformanceKpisEntity {
  const DriverPerformanceKpisEntity({
    required this.totalBoxes,
    required this.deliveredCount,
    required this.deliveredPercentage,
    required this.avgDelayMinutes,
    required this.overallRating,
    required this.failedCount,
    required this.failedPercentage,
    this.totalBoxesText,
    this.deliveredCountText,
    this.deliveredPercentageText,
    this.avgDelayText,
    this.overallRatingText,
    this.failedCountText,
    this.failedPercentageText,
  });

  final int totalBoxes;
  final int deliveredCount;
  final double deliveredPercentage;
  final int avgDelayMinutes;
  final double overallRating;
  final int failedCount;
  final double failedPercentage;

  final String? totalBoxesText;
  final String? deliveredCountText;
  final String? deliveredPercentageText;
  final String? avgDelayText;
  final String? overallRatingText;
  final String? failedCountText;
  final String? failedPercentageText;

  List<DriverPerformanceKpiEntity> toKpiList() {
    final deliveredSub = deliveredPercentageText ??
        '${deliveredPercentage % 1 == 0 ? deliveredPercentage.toInt() : deliveredPercentage.toStringAsFixed(1)}%';
    final failedSub = failedPercentageText ??
        '${failedPercentage % 1 == 0 ? failedPercentage.toInt() : failedPercentage.toStringAsFixed(1)}%';

    return [
      DriverPerformanceKpiEntity(
        id: 'kpi_total_boxes',
        type: DriverPerformanceKpiType.totalBoxes,
        value: totalBoxesText ?? '$totalBoxes',
        subValue: '',
        isHighlighted: true,
      ),
      DriverPerformanceKpiEntity(
        id: 'kpi_delivered',
        type: DriverPerformanceKpiType.delivered,
        value: deliveredCountText ?? '$deliveredCount',
        subValue: deliveredSub,
      ),
      DriverPerformanceKpiEntity(
        id: 'kpi_avg_delay',
        type: DriverPerformanceKpiType.avgDelay,
        value: avgDelayText ?? '$avgDelayMinutes',
        subValue: '',
      ),
      DriverPerformanceKpiEntity(
        id: 'kpi_overall_rating',
        type: DriverPerformanceKpiType.overallRating,
        value: overallRatingText ?? overallRating.toStringAsFixed(1),
        subValue: '',
      ),
      DriverPerformanceKpiEntity(
        id: 'kpi_delivery_failed',
        type: DriverPerformanceKpiType.deliveryFailed,
        value: failedCountText ?? '$failedCount',
        subValue: failedSub,
      ),
    ];
  }
}
