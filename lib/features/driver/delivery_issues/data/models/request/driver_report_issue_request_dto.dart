import 'package:json_annotation/json_annotation.dart';

part 'driver_report_issue_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverReportIssueRequestDto {
  const DriverReportIssueRequestDto({
    required this.issueType,
    this.description,
    this.severity = 'Medium',
    this.evidencePhotoStorageKey,
    this.evidencePhotoStorageKeys,
  });

  factory DriverReportIssueRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverReportIssueRequestDtoFromJson(json);

  final String issueType;
  final String? description;
  final String? severity;
  final String? evidencePhotoStorageKey;
  final List<String>? evidencePhotoStorageKeys;

  Map<String, dynamic> toJson() => _$DriverReportIssueRequestDtoToJson(this);
}
