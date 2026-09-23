import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_live_monitoring_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherLiveMonitoringResponseDto {
  const DispatcherLiveMonitoringResponseDto({this.kpis, this.drivers});

  final DispatcherMapKpiResponseDto? kpis;
  final List<DispatcherMapDriverResponseDto>? drivers;

  factory DispatcherLiveMonitoringResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherLiveMonitoringResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DispatcherMapKpiResponseDto {
  const DispatcherMapKpiResponseDto({
    this.activeDriversCount,
    this.inDeliveryCount,
    this.pausedCount,
    this.issuesCount,
    this.attentionRequiredCount,
  });

  final int? activeDriversCount;
  final int? inDeliveryCount;
  final int? pausedCount;
  final int? issuesCount;
  final int? attentionRequiredCount;

  factory DispatcherMapKpiResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherMapKpiResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DispatcherMapDriverResponseDto {
  const DispatcherMapDriverResponseDto({
    this.id,
    this.driverId,
    this.driverCode,
    this.name,
    this.driverName,
    this.phoneNumber,
    this.phone,
    this.plateNumber,
    this.avatarUrl,
    this.boxId,
    this.boxCode,
    this.tripId,
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.speedKmh,
    this.lastLocationTimestamp,
    this.updatedAtUtc,
    this.status,
    this.statusCategory,
    this.statusText,
    this.statusColor,
    this.topIndicatorColor,
    this.hasIssue,
    this.issueDescription,
    this.lastStatusTimestamp,
    this.locationZone,
    this.remainingDistanceKm,
    this.remainingDistanceText,
    this.remainingDeliveryValue,
  });

  final String? id;
  final String? driverId;
  final String? driverCode;
  final String? name;
  final String? driverName;
  final String? phoneNumber;
  final String? phone;
  final String? plateNumber;
  final String? avatarUrl;
  final String? boxId;
  final String? boxCode;
  final String? tripId;
  final double? latitude;
  final double? longitude;
  final double? heading;
  final double? speed;
  final double? speedKmh;
  final String? lastLocationTimestamp;
  final String? updatedAtUtc;
  final String? status;
  final String? statusCategory;
  final String? statusText;
  final String? statusColor;
  final String? topIndicatorColor;
  final bool? hasIssue;
  final String? issueDescription;
  final String? lastStatusTimestamp;
  final String? locationZone;
  final double? remainingDistanceKm;
  final String? remainingDistanceText;
  final double? remainingDeliveryValue;

  factory DispatcherMapDriverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherMapDriverResponseDtoFromJson(json);
}
