import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_support_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherSupportResponseDto {
  const DispatcherSupportResponseDto({
    this.counters,
    this.areaChips,
    this.issues,
    this.pagination,
  });

  factory DispatcherSupportResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherSupportResponseDtoFromJson(json);

  final DispatcherSupportCountersDto? counters;
  final List<DispatcherSupportAreaChipDto>? areaChips;
  final List<DispatcherSupportIssueDto>? issues;
  final DispatcherSupportPaginationDto? pagination;
}

@JsonSerializable(createToJson: false)
class DispatcherSupportCountersDto {
  const DispatcherSupportCountersDto({
    this.currentArea,
    this.openCount,
    this.missingCount,
    this.inProgressCount,
    this.resolvedCount,
    this.totalCount,
  });

  factory DispatcherSupportCountersDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherSupportCountersDtoFromJson(json);

  final String? currentArea;
  final int? openCount;
  final int? missingCount;
  final int? inProgressCount;
  final int? resolvedCount;
  final int? totalCount;
}

@JsonSerializable(createToJson: false)
class DispatcherSupportAreaChipDto {
  const DispatcherSupportAreaChipDto({
    this.areaKey,
    this.key,
    this.displayName,
    this.name,
    this.count,
  });

  factory DispatcherSupportAreaChipDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherSupportAreaChipDtoFromJson(json);

  final String? areaKey;
  final String? key;
  final String? displayName;
  final String? name;
  final int? count;
}

@JsonSerializable(createToJson: false)
class DispatcherSupportPaginationDto {
  const DispatcherSupportPaginationDto({
    this.pageNumber,
    this.page,
    this.pageSize,
    this.size,
    this.totalCount,
    this.totalItems,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory DispatcherSupportPaginationDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherSupportPaginationDtoFromJson(json);

  final int? pageNumber;
  final int? page;
  final int? pageSize;
  final int? size;
  final int? totalCount;
  final int? totalItems;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPreviousPage;
}

@JsonSerializable(createToJson: false)
class DispatcherSupportIssueDto {
  const DispatcherSupportIssueDto({
    this.id,
    this.issueId,
    this.boxCode,
    this.issueCode,
    this.title,
    this.issueCategory,
    this.badgeText,
    this.categoryLabel,
    this.badgeLabel,
    this.issueCategoryColor,
    this.badgeColor,
    this.categoryColor,
    this.reportedAtUtc,
    this.timeAgo,
    this.reportedTimeText,
    this.driverId,
    this.driverCode,
    this.driverName,
    this.driverAvatar,
    this.driverPhone,
    this.area,
    this.vehicleInfo,
    this.vehicleText,
    this.vehicleModel,
    this.vehicleColor,
    this.priority,
    this.priorityLabel,
    this.priorityColor,
    this.status,
    this.statusLabel,
    this.isDriverActive,
  });

  factory DispatcherSupportIssueDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherSupportIssueDtoFromJson(json);

  final String? id;
  final String? issueId;
  final String? boxCode;
  final String? issueCode;
  final String? title;
  final String? issueCategory;
  final String? badgeText;
  final String? categoryLabel;
  final String? badgeLabel;
  final Object? issueCategoryColor;
  final Object? badgeColor;
  final Object? categoryColor;
  final String? reportedAtUtc;
  final String? timeAgo;
  final String? reportedTimeText;
  final String? driverId;
  final String? driverCode;
  final String? driverName;
  final String? driverAvatar;
  final String? driverPhone;
  final String? area;
  final String? vehicleInfo;
  final String? vehicleText;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? priority;
  final String? priorityLabel;
  final Object? priorityColor;
  final String? status;
  final String? statusLabel;
  final bool? isDriverActive;
}
