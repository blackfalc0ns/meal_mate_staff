import 'package:json_annotation/json_annotation.dart';

part 'driver_details_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverDetailsResponseDto {
  const DriverDetailsResponseDto({
    this.driver,
    this.kpis,
    this.dailySummary,
  });

  factory DriverDetailsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDetailsResponseDtoFromJson(json);

  final DriverProfileDto? driver;
  final DriverKpisDto? kpis;
  final DriverDailySummaryDto? dailySummary;
}

@JsonSerializable(createToJson: false)
class DriverProfileDto {
  const DriverProfileDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.status,
    this.statusText,
    this.statusDotColor,
    this.lastUpdatedText,
  });

  factory DriverProfileDto.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? status;
  final String? statusText;
  final String? statusDotColor;
  final String? lastUpdatedText;
}

@JsonSerializable(createToJson: false)
class DriverKpisDto {
  const DriverKpisDto({
    this.performanceRating,
    this.avgDelayMinutes,
    this.deliveredTodayCount,
    this.activeBoxesCount,
  });

  factory DriverKpisDto.fromJson(Map<String, dynamic> json) =>
      _$DriverKpisDtoFromJson(json);

  final num? performanceRating;
  final num? avgDelayMinutes;
  final num? deliveredTodayCount;
  final num? activeBoxesCount;
}

@JsonSerializable(createToJson: false)
class DriverDailySummaryDto {
  const DriverDailySummaryDto({
    this.approxKm,
    this.avgDelayMinutes,
    this.failedDeliveryCount,
    this.deliveredCount,
  });

  factory DriverDailySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDailySummaryDtoFromJson(json);

  final num? approxKm;
  final num? avgDelayMinutes;
  final num? failedDeliveryCount;
  final num? deliveredCount;
}
