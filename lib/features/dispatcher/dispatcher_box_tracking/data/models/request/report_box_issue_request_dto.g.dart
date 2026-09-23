// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_box_issue_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportBoxIssueRequestDto _$ReportBoxIssueRequestDtoFromJson(
  Map<String, dynamic> json,
) => ReportBoxIssueRequestDto(
  issueType: json['issueType'] as String,
  description: json['description'] as String,
  severity: json['severity'] as String? ?? 'Medium',
);

Map<String, dynamic> _$ReportBoxIssueRequestDtoToJson(
  ReportBoxIssueRequestDto instance,
) => <String, dynamic>{
  'issueType': instance.issueType,
  'description': instance.description,
  'severity': instance.severity,
};
