import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_live_monitoring_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherLiveMonitoringResponseDto {
  const DispatcherLiveMonitoringResponseDto({
    this.kpis,
    this.drivers,
  });

  final DispatcherMapKpiResponseDto? kpis;
  final List<DispatcherMapDriverResponseDto>? drivers;

  factory DispatcherLiveMonitoringResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DispatcherLiveMonitoringResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DispatcherMapKpiResponseDto {
  const DispatcherMapKpiResponseDto({
    this.activeDriversCount,
    this.inDeliveryCount,
    this.pausedCount,
    this.issuesCount,
  });

  final int? activeDriversCount;
  final int? inDeliveryCount;
  final int? pausedCount;
  final int? issuesCount;

  factory DispatcherMapKpiResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherMapKpiResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DispatcherMapDriverResponseDto {
  const DispatcherMapDriverResponseDto({
    this.id,
    this.driverCode,
    this.name,
    this.phoneNumber,
    this.plateNumber,
    this.avatarUrl,
    this.boxId,
    this.tripId,
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.lastLocationTimestamp,
    this.status,
    this.statusText,
    this.statusColor,
    this.hasIssue,
    this.issueDescription,
    this.lastStatusTimestamp,
    this.locationZone,
    this.remainingDistanceKm,
    this.remainingDistanceText,
    this.remainingDeliveryValue,
  });

  final String? id;
  final String? driverCode;
  final String? name;
  final String? phoneNumber;
  final String? plateNumber;
  final String? avatarUrl;
  final String? boxId;
  final String? tripId;
  final double? latitude;
  final double? longitude;
  final double? heading;
  final double? speed;
  final String? lastLocationTimestamp;
  final String? status;
  final String? statusText;
  final String? statusColor;
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
