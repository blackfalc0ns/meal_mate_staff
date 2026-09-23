import 'package:json_annotation/json_annotation.dart';

part 'report_box_issue_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class ReportBoxIssueResponseDto {
  const ReportBoxIssueResponseDto({
    this.issueId,
    this.boxId,
    this.reportedAtUtc,
    this.message,
  });

  factory ReportBoxIssueResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReportBoxIssueResponseDtoFromJson(json);

  final String? issueId;
  final String? boxId;
  final String? reportedAtUtc;
  final String? message;
}
