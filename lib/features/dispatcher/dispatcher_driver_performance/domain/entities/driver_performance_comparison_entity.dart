import 'driver_performance_delay_level.dart';
import 'driver_performance_period.dart';

class DriverComparisonRecordEntity {
  const DriverComparisonRecordEntity({
    required this.driverId,
    required this.driverCode,
    required this.fullName,
    this.avatarUrl,
    required this.totalAssigned,
    required this.deliveredCount,
    required this.deliveredPercentage,
    required this.onTimePercentage,
    required this.avgDelayMinutes,
    required this.delayLevel,
    this.rating,
    required this.failedCount,
    required this.failedPercentage,
    this.totalDistanceKm,
    this.totalAssignedText,
    this.deliveredCountText,
    this.deliveredPercentageText,
    this.onTimePercentageText,
    this.avgDelayText,
    this.ratingText,
    this.failedCountText,
    this.failedPercentageText,
    this.totalDistanceKmText,
  });

  final String driverId;
  final String driverCode;
  final String fullName;
  final String? avatarUrl;
  final int totalAssigned;
  final int deliveredCount;
  final double deliveredPercentage;
  final double onTimePercentage;
  final int avgDelayMinutes;
  final DriverPerformanceDelayLevel delayLevel;
  final double? rating;
  final int failedCount;
  final double failedPercentage;
  final double? totalDistanceKm;

  final String? totalAssignedText;
  final String? deliveredCountText;
  final String? deliveredPercentageText;
  final String? onTimePercentageText;
  final String? avgDelayText;
  final String? ratingText;
  final String? failedCountText;
  final String? failedPercentageText;
  final String? totalDistanceKmText;
}

class DriverPerformanceComparisonEntity {
  const DriverPerformanceComparisonEntity({
    required this.period,
    required this.periodText,
    required this.dateRangeText,
    this.fromDate,
    this.toDate,
    required this.drivers,
  });

  final DriverPerformancePeriod period;
  final String periodText;
  final String dateRangeText;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<DriverComparisonRecordEntity> drivers;
}
