// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_details_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverDetailsResponseDto _$DriverDetailsResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverDetailsResponseDto(
  driver: json['driver'] == null
      ? null
      : DriverProfileDto.fromJson(json['driver'] as Map<String, dynamic>),
  kpis: json['kpis'] == null
      ? null
      : DriverKpisDto.fromJson(json['kpis'] as Map<String, dynamic>),
  dailySummary: json['dailySummary'] == null
      ? null
      : DriverDailySummaryDto.fromJson(
          json['dailySummary'] as Map<String, dynamic>,
        ),
);

DriverProfileDto _$DriverProfileDtoFromJson(Map<String, dynamic> json) =>
    DriverProfileDto(
      driverId: json['driverId'] as String?,
      driverCode: json['driverCode'] as String?,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String?,
      statusText: json['statusText'] as String?,
      statusDotColor: json['statusDotColor'] as String?,
      lastUpdatedText: json['lastUpdatedText'] as String?,
    );

DriverKpisDto _$DriverKpisDtoFromJson(Map<String, dynamic> json) =>
    DriverKpisDto(
      performanceRating: json['performanceRating'] as num?,
      avgDelayMinutes: json['avgDelayMinutes'] as num?,
      deliveredTodayCount: json['deliveredTodayCount'] as num?,
      activeBoxesCount: json['activeBoxesCount'] as num?,
    );

DriverDailySummaryDto _$DriverDailySummaryDtoFromJson(
  Map<String, dynamic> json,
) => DriverDailySummaryDto(
  approxKm: json['approxKm'] as num?,
  avgDelayMinutes: json['avgDelayMinutes'] as num?,
  failedDeliveryCount: json['failedDeliveryCount'] as num?,
  deliveredCount: json['deliveredCount'] as num?,
);
