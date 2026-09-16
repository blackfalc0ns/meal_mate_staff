import 'driver_performance_distribution_category.dart';

class DriverPerformanceDistributionItemEntity {
  const DriverPerformanceDistributionItemEntity({
    required this.id,
    required this.category,
    required this.count,
    required this.percentage,
  });

  final String id;
  final DriverPerformanceDistributionCategory category;
  final int count;
  final double percentage;
}
