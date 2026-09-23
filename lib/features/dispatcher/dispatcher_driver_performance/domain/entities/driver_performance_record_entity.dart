import 'driver_performance_delay_level.dart';
import 'driver_performance_driver_status.dart';

class DriverPerformanceRecordEntity {
  const DriverPerformanceRecordEntity({
    required this.driverId,
    required this.driverCode,
    required this.fullName,
    required this.status,
    required this.deliveredCount,
    required this.deliveredPercentage,
    required this.avgDelayMinutes,
    required this.delayLevel,
    required this.failedDeliveryCount,
    required this.failedDeliveryPercentage,
    required this.rating,
    this.avatarUrl,
    this.statusDotColorKey,
    this.avgDelayColor,
    this.deliveredCountText,
    this.deliveredPercentageText,
    this.avgDelayText,
    this.failedDeliveryCountText,
    this.failedDeliveryPercentageText,
    this.ratingText,
  });

  final String driverId;
  final String driverCode;
  final String fullName;
  final DriverPerformanceDriverStatus status;
  final int deliveredCount;
  final double deliveredPercentage;
  final int avgDelayMinutes;
  final DriverPerformanceDelayLevel delayLevel;
  final int failedDeliveryCount;
  final double failedDeliveryPercentage;
  final double rating;
  final String? avatarUrl;
  final String? statusDotColorKey;
  final String? avgDelayColor;

  final String? deliveredCountText;
  final String? deliveredPercentageText;
  final String? avgDelayText;
  final String? failedDeliveryCountText;
  final String? failedDeliveryPercentageText;
  final String? ratingText;

  // Backward compatibility getters for existing presentation widgets
  String get id => driverId;
  String get name => fullName;
}
