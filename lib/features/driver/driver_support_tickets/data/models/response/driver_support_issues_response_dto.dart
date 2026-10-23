import 'package:json_annotation/json_annotation.dart';

import 'driver_support_issue_summary_dto.dart';

part 'driver_support_issues_response_dto.g.dart';

@JsonSerializable()
class DriverSupportIssuesResponseDto {
  const DriverSupportIssuesResponseDto({
    this.allCount,
    this.underReviewCount,
    this.awaitingReplyCount,
    this.resolvedCount,
    this.totalCount,
    this.pageNumber,
    this.pageSize,
    this.issues,
  });

  factory DriverSupportIssuesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverSupportIssuesResponseDtoFromJson(json);

  final int? allCount;
  final int? underReviewCount;
  final int? awaitingReplyCount;
  final int? resolvedCount;
  final int? totalCount;
  final int? pageNumber;
  final int? pageSize;
  final List<DriverSupportIssueSummaryDto>? issues;

  Map<String, dynamic> toJson() => _$DriverSupportIssuesResponseDtoToJson(this);
}
