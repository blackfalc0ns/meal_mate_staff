import 'package:json_annotation/json_annotation.dart';

import 'dispatcher_issue_details_response_dto.dart';
import 'dispatcher_support_response_dto.dart';

part 'reassign_driver_candidates_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class ReassignDriverCandidatesResponseDto {
  const ReassignDriverCandidatesResponseDto({
    this.summary,
    this.currentDriver,
    this.candidates,
    this.pagination,
  });

  factory ReassignDriverCandidatesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ReassignDriverCandidatesResponseDtoFromJson(json);

  final ReassignDriverIssueSummaryDto? summary;
  final DispatcherIssueDriverDto? currentDriver;
  final List<ReassignDriverCandidateDto>? candidates;
  final DispatcherSupportPaginationDto? pagination;
}

@JsonSerializable(createToJson: false)
class ReassignDriverIssueSummaryDto {
  const ReassignDriverIssueSummaryDto({
    this.issueId,
    this.id,
    this.title,
    this.category,
    this.categoryLabel,
    this.categoryColor,
    this.reportedTimeText,
    this.minutesAgo,
    this.priority,
    this.priorityText,
    this.priorityColor,
    this.taskNumber,
    this.boxCode,
    this.area,
    this.affectedBoxesCount,
    this.affectedBoxesText,
    this.description,
  });

  factory ReassignDriverIssueSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ReassignDriverIssueSummaryDtoFromJson(json);

  final String? issueId;
  final String? id;
  final String? title;
  final String? category;
  final String? categoryLabel;
  final String? categoryColor;
  final String? reportedTimeText;
  final int? minutesAgo;
  final String? priority;
  final String? priorityText;
  final String? priorityColor;
  final String? taskNumber;
  final String? boxCode;
  final String? area;
  final int? affectedBoxesCount;
  final String? affectedBoxesText;
  final String? description;
}

@JsonSerializable(createToJson: false)
class ReassignDriverCandidateDto {
  const ReassignDriverCandidateDto({
    this.id,
    this.driverId,
    this.name,
    this.code,
    this.avatarUrl,
    this.isAvailable,
    this.status,
    this.statusText,
    this.statusColorHex,
    this.rating,
    this.activeOrdersCount,
    this.ordersCount,
    this.area,
    this.isSameArea,
    this.distanceKm,
    this.distanceText,
    this.estimatedArrivalMinutes,
    this.estimatedArrivalText,
    this.vehicleInfo,
    this.lastLocationUpdate,
    this.lastLocationUpdateUtc,
    this.lastLocationUpdateText,
    this.recommendationRank,
    this.rank,
  });

  factory ReassignDriverCandidateDto.fromJson(Map<String, dynamic> json) =>
      _$ReassignDriverCandidateDtoFromJson(json);

  final String? id;
  final String? driverId;
  final String? name;
  final String? code;
  final String? avatarUrl;
  final bool? isAvailable;
  final String? status;
  final String? statusText;
  final String? statusColorHex;
  final double? rating;
  final int? activeOrdersCount;
  final int? ordersCount;
  final String? area;
  final bool? isSameArea;
  final double? distanceKm;
  final String? distanceText;
  final int? estimatedArrivalMinutes;
  final String? estimatedArrivalText;
  final String? vehicleInfo;
  final String? lastLocationUpdate;
  final String? lastLocationUpdateUtc;
  final String? lastLocationUpdateText;
  final int? recommendationRank;
  final int? rank;
}
