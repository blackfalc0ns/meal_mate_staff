import 'package:json_annotation/json_annotation.dart';

part 'driver_performance_overview_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverPerformanceOverviewResponseDto {
  const DriverPerformanceOverviewResponseDto({
    this.period,
    this.periodText,
    this.dateRangeText,
    this.fromDate,
    this.toDate,
    this.kpis,
    this.distribution,
    this.topDrivers,
    this.driversTable,
  });

  factory DriverPerformanceOverviewResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformanceOverviewResponseDtoFromJson(json);

  final String? period;
  final String? periodText;
  final String? dateRangeText;
  final String? fromDate;
  final String? toDate;
  final DriverPerformanceKpisResponseDto? kpis;
  final DriverPerformanceDistributionResponseDto? distribution;
  final List<DriverPerformancePodiumResponseDto>? topDrivers;
  final List<DriverPerformanceTableRowResponseDto>? driversTable;
}

@JsonSerializable(createToJson: false)
class DriverPerformanceKpisResponseDto {
  const DriverPerformanceKpisResponseDto({
    this.totalBoxes,
    this.totalBoxesText,
    this.deliveredCount,
    this.deliveredCountText,
    this.deliveredPercentage,
    this.deliveredPercentageText,
    this.avgDelayMinutes,
    this.avgDelayText,
    this.overallRating,
    this.overallRatingText,
    this.failedCount,
    this.failedCountText,
    this.failedPercentage,
    this.failedPercentageText,
  });

  factory DriverPerformanceKpisResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformanceKpisResponseDtoFromJson(json);

  final int? totalBoxes;
  final String? totalBoxesText;
  final int? deliveredCount;
  final String? deliveredCountText;
  final double? deliveredPercentage;
  final String? deliveredPercentageText;
  final int? avgDelayMinutes;
  final String? avgDelayText;
  final double? overallRating;
  final String? overallRatingText;
  final int? failedCount;
  final String? failedCountText;
  final double? failedPercentage;
  final String? failedPercentageText;
}

@JsonSerializable(createToJson: false)
class DriverPerformanceDistributionResponseDto {
  const DriverPerformanceDistributionResponseDto({
    this.totalBoxes,
    this.totalCount,
    this.segments,
  });

  factory DriverPerformanceDistributionResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformanceDistributionResponseDtoFromJson(json);

  final int? totalBoxes;
  final int? totalCount;
  final List<DriverPerformanceDistributionSegmentResponseDto>? segments;
}

@JsonSerializable(createToJson: false)
class DriverPerformanceDistributionSegmentResponseDto {
  const DriverPerformanceDistributionSegmentResponseDto({
    this.id,
    this.key,
    this.name,
    this.title,
    this.count,
    this.percentage,
    this.color,
    this.colorHex,
  });

  factory DriverPerformanceDistributionSegmentResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformanceDistributionSegmentResponseDtoFromJson(json);

  final String? id;
  final String? key;
  final String? name;
  final String? title;
  final int? count;
  final double? percentage;
  final String? color;
  final String? colorHex;
}

@JsonSerializable(createToJson: false)
class DriverPerformancePodiumResponseDto {
  const DriverPerformancePodiumResponseDto({
    this.rank,
    this.driverId,
    this.driverCode,
    this.name,
    this.fullName,
    this.rating,
    this.avatarUrl,
    this.isHighlighted,
  });

  factory DriverPerformancePodiumResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformancePodiumResponseDtoFromJson(json);

  final int? rank;
  final String? driverId;
  final String? driverCode;
  final String? name;
  final String? fullName;
  final double? rating;
  final String? avatarUrl;
  final bool? isHighlighted;
}

@JsonSerializable(createToJson: false)
class DriverPerformanceTableRowResponseDto {
  const DriverPerformanceTableRowResponseDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.name,
    this.avatarUrl,
    this.status,
    this.statusDotColor,
    this.statusDotColorKey,
    this.deliveredCount,
    this.deliveredCountText,
    this.deliveredPercentage,
    this.deliveredPercentageText,
    this.deliveredRate,
    this.deliveredRateText,
    this.avgDelayMinutes,
    this.avgDelayText,
    this.avgDelayColor,
    this.delayLevel,
    this.avgDelayLevel,
    this.failedDeliveryCount,
    this.failedDeliveryCountText,
    this.failedCount,
    this.failedCountText,
    this.failedDeliveryPercentage,
    this.failedDeliveryPercentageText,
    this.failedRate,
    this.failedRateText,
    this.rating,
    this.ratingText,
  });

  factory DriverPerformanceTableRowResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPerformanceTableRowResponseDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? name;
  final String? avatarUrl;
  final String? status;
  final String? statusDotColor;
  final String? statusDotColorKey;
  final int? deliveredCount;
  final String? deliveredCountText;
  final double? deliveredPercentage;
  final String? deliveredPercentageText;
  final double? deliveredRate;
  final String? deliveredRateText;
  final int? avgDelayMinutes;
  final String? avgDelayText;
  final String? avgDelayColor;
  final String? delayLevel;
  final String? avgDelayLevel;
  final int? failedDeliveryCount;
  final String? failedDeliveryCountText;
  final int? failedCount;
  final String? failedCountText;
  final double? failedDeliveryPercentage;
  final String? failedDeliveryPercentageText;
  final double? failedRate;
  final String? failedRateText;
  final double? rating;
  final String? ratingText;
}
