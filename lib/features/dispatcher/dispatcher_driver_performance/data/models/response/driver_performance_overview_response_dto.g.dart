// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_performance_overview_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverPerformanceOverviewResponseDto
_$DriverPerformanceOverviewResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPerformanceOverviewResponseDto(
  period: json['period'] as String?,
  periodText: json['periodText'] as String?,
  dateRangeText: json['dateRangeText'] as String?,
  fromDate: json['fromDate'] as String?,
  toDate: json['toDate'] as String?,
  kpis: json['kpis'] == null
      ? null
      : DriverPerformanceKpisResponseDto.fromJson(
          json['kpis'] as Map<String, dynamic>,
        ),
  distribution: json['distribution'] == null
      ? null
      : DriverPerformanceDistributionResponseDto.fromJson(
          json['distribution'] as Map<String, dynamic>,
        ),
  topDrivers: (json['topDrivers'] as List<dynamic>?)
      ?.map(
        (e) => DriverPerformancePodiumResponseDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  driversTable: (json['driversTable'] as List<dynamic>?)
      ?.map(
        (e) => DriverPerformanceTableRowResponseDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

DriverPerformanceKpisResponseDto _$DriverPerformanceKpisResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPerformanceKpisResponseDto(
  totalBoxes: (json['totalBoxes'] as num?)?.toInt(),
  totalBoxesText: json['totalBoxesText'] as String?,
  deliveredCount: (json['deliveredCount'] as num?)?.toInt(),
  deliveredCountText: json['deliveredCountText'] as String?,
  deliveredPercentage: (json['deliveredPercentage'] as num?)?.toDouble(),
  deliveredPercentageText: json['deliveredPercentageText'] as String?,
  avgDelayMinutes: (json['avgDelayMinutes'] as num?)?.toInt(),
  avgDelayText: json['avgDelayText'] as String?,
  overallRating: (json['overallRating'] as num?)?.toDouble(),
  overallRatingText: json['overallRatingText'] as String?,
  failedCount: (json['failedCount'] as num?)?.toInt(),
  failedCountText: json['failedCountText'] as String?,
  failedPercentage: (json['failedPercentage'] as num?)?.toDouble(),
  failedPercentageText: json['failedPercentageText'] as String?,
);

DriverPerformanceDistributionResponseDto
_$DriverPerformanceDistributionResponseDtoFromJson(Map<String, dynamic> json) =>
    DriverPerformanceDistributionResponseDto(
      totalBoxes: (json['totalBoxes'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      segments: (json['segments'] as List<dynamic>?)
          ?.map(
            (e) => DriverPerformanceDistributionSegmentResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

DriverPerformanceDistributionSegmentResponseDto
_$DriverPerformanceDistributionSegmentResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPerformanceDistributionSegmentResponseDto(
  id: json['id'] as String?,
  key: json['key'] as String?,
  name: json['name'] as String?,
  title: json['title'] as String?,
  count: (json['count'] as num?)?.toInt(),
  percentage: (json['percentage'] as num?)?.toDouble(),
  color: json['color'] as String?,
  colorHex: json['colorHex'] as String?,
);

DriverPerformancePodiumResponseDto _$DriverPerformancePodiumResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPerformancePodiumResponseDto(
  rank: (json['rank'] as num?)?.toInt(),
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  name: json['name'] as String?,
  fullName: json['fullName'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  avatarUrl: json['avatarUrl'] as String?,
  isHighlighted: json['isHighlighted'] as bool?,
);

DriverPerformanceTableRowResponseDto
_$DriverPerformanceTableRowResponseDtoFromJson(Map<String, dynamic> json) =>
    DriverPerformanceTableRowResponseDto(
      driverId: json['driverId'] as String?,
      driverCode: json['driverCode'] as String?,
      fullName: json['fullName'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String?,
      statusDotColor: json['statusDotColor'] as String?,
      statusDotColorKey: json['statusDotColorKey'] as String?,
      deliveredCount: (json['deliveredCount'] as num?)?.toInt(),
      deliveredCountText: json['deliveredCountText'] as String?,
      deliveredPercentage: (json['deliveredPercentage'] as num?)?.toDouble(),
      deliveredPercentageText: json['deliveredPercentageText'] as String?,
      deliveredRate: (json['deliveredRate'] as num?)?.toDouble(),
      deliveredRateText: json['deliveredRateText'] as String?,
      avgDelayMinutes: (json['avgDelayMinutes'] as num?)?.toInt(),
      avgDelayText: json['avgDelayText'] as String?,
      avgDelayColor: json['avgDelayColor'] as String?,
      delayLevel: json['delayLevel'] as String?,
      avgDelayLevel: json['avgDelayLevel'] as String?,
      failedDeliveryCount: (json['failedDeliveryCount'] as num?)?.toInt(),
      failedDeliveryCountText: json['failedDeliveryCountText'] as String?,
      failedCount: (json['failedCount'] as num?)?.toInt(),
      failedCountText: json['failedCountText'] as String?,
      failedDeliveryPercentage: (json['failedDeliveryPercentage'] as num?)
          ?.toDouble(),
      failedDeliveryPercentageText:
          json['failedDeliveryPercentageText'] as String?,
      failedRate: (json['failedRate'] as num?)?.toDouble(),
      failedRateText: json['failedRateText'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingText: json['ratingText'] as String?,
    );
