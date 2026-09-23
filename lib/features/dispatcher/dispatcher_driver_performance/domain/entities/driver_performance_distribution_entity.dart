import 'driver_performance_distribution_item_entity.dart';

class DriverPerformanceDistributionEntity {
  const DriverPerformanceDistributionEntity({
    required this.totalBoxes,
    required this.segments,
  });

  final int totalBoxes;
  final List<DriverPerformanceDistributionItemEntity> segments;
}
