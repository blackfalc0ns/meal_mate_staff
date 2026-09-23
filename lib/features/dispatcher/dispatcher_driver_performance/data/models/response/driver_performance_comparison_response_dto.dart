import 'package:json_annotation/json_annotation.dart';

part 'driver_performance_comparison_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverPerformanceComparisonResponseDto {
  const DriverPerformanceComparisonResponseDto({
    this.period,
    this.periodText,
    this.dateRangeText,
    this.fromDate,
    this.toDate,
    this.drivers,
  });

  factory DriverPerformanceComparisonResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformanceComparisonResponseDtoFromJson(json);

  final String? period;
  final String? periodText;
  final String? dateRangeText;
  final String? fromDate;
  final String? toDate;
  final List<DriverComparisonDriverResponseDto>? drivers;
}

@JsonSerializable(createToJson: false)
class DriverComparisonDriverResponseDto {
  const DriverComparisonDriverResponseDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.avatarUrl,
    this.totalAssigned,
    this.totalAssignedText,
    this.deliveredCount,
    this.deliveredCountText,
    this.deliveredPercentage,
    this.deliveredPercentageText,
    this.deliveredRate,
    this.deliveredRateText,
    this.onTimePercentage,
    this.onTimePercentageText,
    this.avgDelayMinutes,
    this.avgDelayText,
    this.delayLevel,
    this.avgDelayLevel,
    this.rating,
    this.ratingText,
    this.failedCount,
    this.failedCountText,
    this.failedPercentage,
    this.failedPercentageText,
    this.failedRate,
    this.failedRateText,
    this.totalDistanceKm,
    this.totalDistanceKmText,
  });

  factory DriverComparisonDriverResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverComparisonDriverResponseDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? avatarUrl;
  final int? totalAssigned;
  final String? totalAssignedText;
  final int? deliveredCount;
  final String? deliveredCountText;
  final double? deliveredPercentage;
  final String? deliveredPercentageText;
  final double? deliveredRate;
  final String? deliveredRateText;
  final double? onTimePercentage;
  final String? onTimePercentageText;
  final int? avgDelayMinutes;
  final String? avgDelayText;
  final String? delayLevel;
  final String? avgDelayLevel;
  final double? rating;
  final String? ratingText;
  final int? failedCount;
  final String? failedCountText;
  final double? failedPercentage;
  final String? failedPercentageText;
  final double? failedRate;
  final String? failedRateText;
  final double? totalDistanceKm;
  final String? totalDistanceKmText;
}
