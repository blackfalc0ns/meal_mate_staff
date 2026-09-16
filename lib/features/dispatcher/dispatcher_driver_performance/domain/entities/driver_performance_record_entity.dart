import '../../../dispatcher_drivers/domain/entities/dispatcher_driver_status.dart';

class DriverPerformanceRecordEntity {
  const DriverPerformanceRecordEntity({
    required this.id,
    required this.name,
    required this.driverCode,
    required this.deliveredCount,
    required this.deliveredPercentage,
    required this.avgDelayMinutes,
    required this.failedDeliveryCount,
    required this.failedDeliveryPercentage,
    required this.rating,
    required this.status,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String driverCode;
  final String deliveredCount;
  final String deliveredPercentage;
  final int avgDelayMinutes;
  final String failedDeliveryCount;
  final String failedDeliveryPercentage;
  final double rating;
  final DispatcherDriverStatus status;
  final String? avatarUrl;
}
