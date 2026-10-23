import 'package:json_annotation/json_annotation.dart';

import 'driver_support_timeline_step_dto.dart';

part 'driver_support_issue_details_response_dto.g.dart';

@JsonSerializable()
class DriverSupportIssueDetailsResponseDto {
  const DriverSupportIssueDetailsResponseDto({
    this.issueId,
    this.category,
    this.categoryLabel,
    this.title,
    this.description,
    this.status,
    this.rawStatus,
    this.statusLabel,
    this.submittedAtUtc,
    this.updatedAtUtc,
    this.orderCode,
    this.address,
    this.area,
    this.orderCreatedAtUtc,
    this.timeline,
    this.evidenceUrls,
    this.resolutionNotes,
    this.resolvedAtUtc,
    this.canContactSupport,
    this.contactChannel,
  });

  factory DriverSupportIssueDetailsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverSupportIssueDetailsResponseDtoFromJson(json);

  final String? issueId;
  final String? category;
  final String? categoryLabel;
  final String? title;
  final String? description;
  final String? status;
  final String? rawStatus;
  final String? statusLabel;
  final String? submittedAtUtc;
  final String? updatedAtUtc;
  final String? orderCode;
  final String? address;
  final String? area;
  final String? orderCreatedAtUtc;
  final List<DriverSupportTimelineStepDto>? timeline;
  final List<String>? evidenceUrls;
  final String? resolutionNotes;
  final String? resolvedAtUtc;
  final bool? canContactSupport;
  final String? contactChannel;

  Map<String, dynamic> toJson() =>
      _$DriverSupportIssueDetailsResponseDtoToJson(this);
}
