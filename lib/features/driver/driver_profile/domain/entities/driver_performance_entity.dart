import 'driver_performance_metric_card_entity.dart';

class DriverPerformanceEntity {
  const DriverPerformanceEntity({
    required this.formattedDate,
    required this.isOnline,
    required this.totalOrders,
    required this.onTimeRate,
    required this.deliveriesCount,
    required this.totalDistance,
    required this.onTimeCard,
    required this.deliveriesCard,
    required this.distanceCard,
    required this.workingHoursCard,
  });

  final String formattedDate;
  final bool isOnline;
  final int totalOrders;
  final String onTimeRate;
  final int deliveriesCount;
  final String totalDistance;
  final DriverPerformanceMetricCardEntity onTimeCard;
  final DriverPerformanceMetricCardEntity deliveriesCard;
  final DriverPerformanceMetricCardEntity distanceCard;
  final DriverPerformanceMetricCardEntity workingHoursCard;
}
