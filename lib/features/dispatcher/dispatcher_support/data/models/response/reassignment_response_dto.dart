import 'package:json_annotation/json_annotation.dart';

import 'dispatcher_issue_details_response_dto.dart';

part 'reassignment_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class ReassignmentResponseDto {
  const ReassignmentResponseDto({
    this.issueId,
    this.id,
    this.status,
    this.statusLabel,
    this.reassignedDriver,
    this.message,
    this.resolution,
  });

  factory ReassignmentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReassignmentResponseDtoFromJson(json);

  final String? issueId;
  final String? id;
  final String? status;
  final String? statusLabel;
  final DispatcherIssueDriverDto? reassignedDriver;
  final String? message;
  final DispatcherIssueResolutionDto? resolution;
}
