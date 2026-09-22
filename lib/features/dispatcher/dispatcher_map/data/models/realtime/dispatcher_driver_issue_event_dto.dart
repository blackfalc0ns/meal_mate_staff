import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_driver_issue_event_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDriverIssueEventDto {
  const DispatcherDriverIssueEventDto({
    this.driverId,
    this.hasIssue,
    this.issueDescription,
    this.timestamp,
  });

  final String? driverId;
  final bool? hasIssue;
  final String? issueDescription;
  final String? timestamp;

  factory DispatcherDriverIssueEventDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverIssueEventDtoFromJson(json);
}
