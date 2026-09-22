// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_support_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherSupportResponseDto _$DispatcherSupportResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherSupportResponseDto(
  counters: json['counters'] == null
      ? null
      : DispatcherSupportCountersDto.fromJson(
          json['counters'] as Map<String, dynamic>,
        ),
  areaChips: (json['areaChips'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherSupportAreaChipDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  issues: (json['issues'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherSupportIssueDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : DispatcherSupportPaginationDto.fromJson(
          json['pagination'] as Map<String, dynamic>,
        ),
);

DispatcherSupportCountersDto _$DispatcherSupportCountersDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherSupportCountersDto(
  currentArea: json['currentArea'] as String?,
  openCount: (json['openCount'] as num?)?.toInt(),
  missingCount: (json['missingCount'] as num?)?.toInt(),
  inProgressCount: (json['inProgressCount'] as num?)?.toInt(),
  resolvedCount: (json['resolvedCount'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
);

DispatcherSupportAreaChipDto _$DispatcherSupportAreaChipDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherSupportAreaChipDto(
  areaKey: json['areaKey'] as String?,
  key: json['key'] as String?,
  displayName: json['displayName'] as String?,
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
);

DispatcherSupportPaginationDto _$DispatcherSupportPaginationDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherSupportPaginationDto(
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  page: (json['page'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  size: (json['size'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalItems: (json['totalItems'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  hasNextPage: json['hasNextPage'] as bool?,
  hasPreviousPage: json['hasPreviousPage'] as bool?,
);

DispatcherSupportIssueDto _$DispatcherSupportIssueDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherSupportIssueDto(
  id: json['id'] as String?,
  issueId: json['issueId'] as String?,
  boxCode: json['boxCode'] as String?,
  issueCode: json['issueCode'] as String?,
  title: json['title'] as String?,
  issueCategory: json['issueCategory'] as String?,
  badgeText: json['badgeText'] as String?,
  categoryLabel: json['categoryLabel'] as String?,
  badgeLabel: json['badgeLabel'] as String?,
  issueCategoryColor: json['issueCategoryColor'],
  badgeColor: json['badgeColor'],
  categoryColor: json['categoryColor'],
  reportedAtUtc: json['reportedAtUtc'] as String?,
  timeAgo: json['timeAgo'] as String?,
  reportedTimeText: json['reportedTimeText'] as String?,
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  driverName: json['driverName'] as String?,
  driverAvatar: json['driverAvatar'] as String?,
  driverPhone: json['driverPhone'] as String?,
  area: json['area'] as String?,
  vehicleInfo: json['vehicleInfo'] as String?,
  vehicleText: json['vehicleText'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  vehicleColor: json['vehicleColor'] as String?,
  priority: json['priority'] as String?,
  priorityLabel: json['priorityLabel'] as String?,
  priorityColor: json['priorityColor'],
  status: json['status'] as String?,
  statusLabel: json['statusLabel'] as String?,
  isDriverActive: json['isDriverActive'] as bool?,
);
