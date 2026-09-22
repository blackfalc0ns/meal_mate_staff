// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reassign_driver_candidates_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReassignDriverCandidatesResponseDto
_$ReassignDriverCandidatesResponseDtoFromJson(Map<String, dynamic> json) =>
    ReassignDriverCandidatesResponseDto(
      summary: json['summary'] == null
          ? null
          : ReassignDriverIssueSummaryDto.fromJson(
              json['summary'] as Map<String, dynamic>,
            ),
      issue: json['issue'] == null
          ? null
          : ReassignDriverIssueSummaryDto.fromJson(
              json['issue'] as Map<String, dynamic>,
            ),
      currentDriver: json['currentDriver'] == null
          ? null
          : DispatcherIssueDriverDto.fromJson(
              json['currentDriver'] as Map<String, dynamic>,
            ),
      candidates: (json['candidates'] as List<dynamic>?)
          ?.map(
            (e) =>
                ReassignDriverCandidateDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : DispatcherSupportPaginationDto.fromJson(
              json['pagination'] as Map<String, dynamic>,
            ),
    );

ReassignDriverIssueSummaryDto _$ReassignDriverIssueSummaryDtoFromJson(
  Map<String, dynamic> json,
) => ReassignDriverIssueSummaryDto(
  issueId: json['issueId'] as String?,
  id: json['id'] as String?,
  title: json['title'] as String?,
  category: json['category'] as String?,
  categoryLabel: json['categoryLabel'] as String?,
  categoryColor: json['categoryColor'] as String?,
  createdAtUtc: json['createdAtUtc'] as String?,
  reportedTimeText: json['reportedTimeText'] as String?,
  minutesAgo: (json['minutesAgo'] as num?)?.toInt(),
  priority: json['priority'] as String?,
  priorityText: json['priorityText'] as String?,
  priorityColor: json['priorityColor'] as String?,
  taskNumber: json['taskNumber'] as String?,
  boxCode: json['boxCode'] as String?,
  area: json['area'] as String?,
  affectedBoxesCount: (json['affectedBoxesCount'] as num?)?.toInt(),
  affectedBoxesText: json['affectedBoxesText'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String?,
);

ReassignDriverCandidateDto _$ReassignDriverCandidateDtoFromJson(
  Map<String, dynamic> json,
) => ReassignDriverCandidateDto(
  id: json['id'] as String?,
  driverId: json['driverId'] as String?,
  name: json['name'] as String?,
  fullName: json['fullName'] as String?,
  code: json['code'] as String?,
  driverCode: json['driverCode'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isAvailable: json['isAvailable'] as bool?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  statusColor: json['statusColor'] as String?,
  statusColorHex: json['statusColorHex'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  activeOrdersCount: (json['activeOrdersCount'] as num?)?.toInt(),
  ordersCount: (json['ordersCount'] as num?)?.toInt(),
  area: json['area'] as String?,
  isSameArea: json['isSameArea'] as bool?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  distanceText: json['distanceText'] as String?,
  estimatedArrivalMinutes: (json['estimatedArrivalMinutes'] as num?)?.toInt(),
  estimatedArrivalText: json['estimatedArrivalText'] as String?,
  vehicleInfo: json['vehicleInfo'] as String?,
  lastLocationUpdate: json['lastLocationUpdate'] as String?,
  lastLocationUpdateUtc: json['lastLocationUpdateUtc'] as String?,
  lastLocationUpdatedAtUtc: json['lastLocationUpdatedAtUtc'] as String?,
  lastLocationUpdateText: json['lastLocationUpdateText'] as String?,
  recommendationRank: (json['recommendationRank'] as num?)?.toInt(),
  rank: (json['rank'] as num?)?.toInt(),
);
