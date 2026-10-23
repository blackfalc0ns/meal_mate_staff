import 'package:json_annotation/json_annotation.dart';

part 'driver_support_issue_summary_dto.g.dart';

@JsonSerializable()
class DriverSupportIssueSummaryDto {
  const DriverSupportIssueSummaryDto({
    this.issueId,
    this.category,
    this.categoryLabel,
    this.title,
    this.status,
    this.statusLabel,
    this.submittedAtUtc,
    this.orderCode,
  });

  factory DriverSupportIssueSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DriverSupportIssueSummaryDtoFromJson(json);

  final String? issueId;
  final String? category;
  final String? categoryLabel;
  final String? title;
  final String? status;
  final String? statusLabel;
  final String? submittedAtUtc;
  final String? orderCode;

  Map<String, dynamic> toJson() => _$DriverSupportIssueSummaryDtoToJson(this);
}
