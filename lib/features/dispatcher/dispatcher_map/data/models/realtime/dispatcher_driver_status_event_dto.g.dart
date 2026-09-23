// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_driver_status_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherDriverStatusEventDto _$DispatcherDriverStatusEventDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverStatusEventDto(
  driverId: json['driverId'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  statusColor: json['statusColor'] as String?,
  hasIssue: json['hasIssue'] as bool?,
  issueDescription: json['issueDescription'] as String?,
  timestamp:
      DispatcherDriverStatusEventDto._readRecordedAt(json, 'timestamp')
          as String?,
  kpis: json['kpis'] == null
      ? null
      : DispatcherMapKpiResponseDto.fromJson(
          json['kpis'] as Map<String, dynamic>,
        ),
  activeBoxesCount: (json['activeBoxesCount'] as num?)?.toInt(),
);
