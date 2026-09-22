import 'package:json_annotation/json_annotation.dart';

import 'dispatcher_issue_details_response_dto.dart';

part 'resolve_issue_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class ResolveIssueResponseDto {
  const ResolveIssueResponseDto({
    this.issueId,
    this.id,
    this.status,
    this.statusLabel,
    this.resolution,
    this.message,
  });

  factory ResolveIssueResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ResolveIssueResponseDtoFromJson(json);

  final String? issueId;
  final String? id;
  final String? status;
  final String? statusLabel;
  final DispatcherIssueResolutionDto? resolution;
  final String? message;
}
