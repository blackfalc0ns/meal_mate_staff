// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_live_monitoring_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherLiveMonitoringResponseDto
_$DispatcherLiveMonitoringResponseDtoFromJson(Map<String, dynamic> json) =>
    DispatcherLiveMonitoringResponseDto(
      kpis: json['kpis'] == null
          ? null
          : DispatcherMapKpiResponseDto.fromJson(
              json['kpis'] as Map<String, dynamic>,
            ),
      drivers: (json['drivers'] as List<dynamic>?)
          ?.map(
            (e) => DispatcherMapDriverResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

DispatcherMapKpiResponseDto _$DispatcherMapKpiResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherMapKpiResponseDto(
  activeDriversCount: (json['activeDriversCount'] as num?)?.toInt(),
  inDeliveryCount: (json['inDeliveryCount'] as num?)?.toInt(),
  pausedCount: (json['pausedCount'] as num?)?.toInt(),
  issuesCount: (json['issuesCount'] as num?)?.toInt(),
  attentionRequiredCount: (json['attentionRequiredCount'] as num?)?.toInt(),
);

DispatcherMapDriverResponseDto _$DispatcherMapDriverResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherMapDriverResponseDto(
  id: json['id'] as String?,
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  name: json['name'] as String?,
  driverName: json['driverName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  phone: json['phone'] as String?,
  plateNumber: json['plateNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  tripId: json['tripId'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  speedKmh: (json['speedKmh'] as num?)?.toDouble(),
  lastLocationTimestamp: json['lastLocationTimestamp'] as String?,
  updatedAtUtc: json['updatedAtUtc'] as String?,
  status: json['status'] as String?,
  statusCategory: json['statusCategory'] as String?,
  statusText: json['statusText'] as String?,
  statusColor: json['statusColor'] as String?,
  topIndicatorColor: json['topIndicatorColor'] as String?,
  hasIssue: json['hasIssue'] as bool?,
  issueDescription: json['issueDescription'] as String?,
  lastStatusTimestamp: json['lastStatusTimestamp'] as String?,
  locationZone: json['locationZone'] as String?,
  remainingDistanceKm: (json['remainingDistanceKm'] as num?)?.toDouble(),
  remainingDistanceText: json['remainingDistanceText'] as String?,
  remainingDeliveryValue: (json['remainingDeliveryValue'] as num?)?.toDouble(),
);
