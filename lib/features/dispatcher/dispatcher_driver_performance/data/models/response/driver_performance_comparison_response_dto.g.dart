// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_performance_comparison_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverPerformanceComparisonResponseDto
_$DriverPerformanceComparisonResponseDtoFromJson(Map<String, dynamic> json) =>
    DriverPerformanceComparisonResponseDto(
      period: json['period'] as String?,
      periodText: json['periodText'] as String?,
      dateRangeText: json['dateRangeText'] as String?,
      fromDate: json['fromDate'] as String?,
      toDate: json['toDate'] as String?,
      drivers: (json['drivers'] as List<dynamic>?)
          ?.map(
            (e) => DriverComparisonDriverResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

DriverComparisonDriverResponseDto _$DriverComparisonDriverResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverComparisonDriverResponseDto(
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  totalAssigned: (json['totalAssigned'] as num?)?.toInt(),
  totalAssignedText: json['totalAssignedText'] as String?,
  deliveredCount: (json['deliveredCount'] as num?)?.toInt(),
  deliveredCountText: json['deliveredCountText'] as String?,
  deliveredPercentage: (json['deliveredPercentage'] as num?)?.toDouble(),
  deliveredPercentageText: json['deliveredPercentageText'] as String?,
  deliveredRate: (json['deliveredRate'] as num?)?.toDouble(),
  deliveredRateText: json['deliveredRateText'] as String?,
  onTimePercentage: (json['onTimePercentage'] as num?)?.toDouble(),
  onTimePercentageText: json['onTimePercentageText'] as String?,
  avgDelayMinutes: (json['avgDelayMinutes'] as num?)?.toInt(),
  avgDelayText: json['avgDelayText'] as String?,
  delayLevel: json['delayLevel'] as String?,
  avgDelayLevel: json['avgDelayLevel'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  ratingText: json['ratingText'] as String?,
  failedCount: (json['failedCount'] as num?)?.toInt(),
  failedCountText: json['failedCountText'] as String?,
  failedPercentage: (json['failedPercentage'] as num?)?.toDouble(),
  failedPercentageText: json['failedPercentageText'] as String?,
  failedRate: (json['failedRate'] as num?)?.toDouble(),
  failedRateText: json['failedRateText'] as String?,
  totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble(),
  totalDistanceKmText: json['totalDistanceKmText'] as String?,
);
