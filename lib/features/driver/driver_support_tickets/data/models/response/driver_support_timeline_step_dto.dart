import 'package:json_annotation/json_annotation.dart';

part 'driver_support_timeline_step_dto.g.dart';

@JsonSerializable()
class DriverSupportTimelineStepDto {
  const DriverSupportTimelineStepDto({
    this.stage,
    this.label,
    this.state,
    this.occurredAtUtc,
  });

  factory DriverSupportTimelineStepDto.fromJson(Map<String, dynamic> json) =>
      _$DriverSupportTimelineStepDtoFromJson(json);

  final String? stage;
  final String? label;
  final String? state;
  final String? occurredAtUtc;

  Map<String, dynamic> toJson() => _$DriverSupportTimelineStepDtoToJson(this);
}
