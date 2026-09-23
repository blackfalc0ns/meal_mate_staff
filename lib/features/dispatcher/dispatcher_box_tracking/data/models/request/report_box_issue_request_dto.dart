import 'package:json_annotation/json_annotation.dart';

part 'report_box_issue_request_dto.g.dart';

@JsonSerializable()
class ReportBoxIssueRequestDto {
  const ReportBoxIssueRequestDto({
    required this.issueType,
    required this.description,
    this.severity = 'Medium',
  });

  factory ReportBoxIssueRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReportBoxIssueRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportBoxIssueRequestDtoToJson(this);

  final String issueType;
  final String description;
  final String severity;
}
