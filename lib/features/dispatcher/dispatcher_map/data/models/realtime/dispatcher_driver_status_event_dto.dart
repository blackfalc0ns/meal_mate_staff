import 'package:json_annotation/json_annotation.dart';

import '../response/dispatcher_live_monitoring_response_dto.dart';

part 'dispatcher_driver_status_event_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDriverStatusEventDto {
  const DispatcherDriverStatusEventDto({
    this.driverId,
    this.status,
    this.statusText,
    this.statusColor,
    this.hasIssue,
    this.issueDescription,
    this.timestamp,
    this.kpis,
    this.activeBoxesCount,
  });

  final String? driverId;
  final String? status;
  final String? statusText;
  final String? statusColor;
  final bool? hasIssue;
  final String? issueDescription;

  @JsonKey(readValue: _readRecordedAt)
  final String? timestamp;

  final DispatcherMapKpiResponseDto? kpis;
  final int? activeBoxesCount;

  static Object? _readRecordedAt(Map json, String key) =>
      json['recordedAtUtc'] ?? json['timestamp'];

  factory DispatcherDriverStatusEventDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverStatusEventDtoFromJson(json);
}
