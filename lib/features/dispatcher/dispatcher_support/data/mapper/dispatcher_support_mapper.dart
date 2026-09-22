import '../../domain/entities/dispatcher_support_issue_entity.dart';
import '../../domain/entities/dispatcher_support_issue_type.dart';
import '../../domain/entities/dispatcher_support_kpi_entity.dart';
import '../../domain/entities/dispatcher_support_response_entity.dart';
import '../../domain/entities/dispatcher_support_status.dart';
import '../models/response/dispatcher_support_response_dto.dart';

extension DispatcherSupportResponseDtoMapper on DispatcherSupportResponseDto {
  DispatcherSupportResponseEntity toEntity() {
    return DispatcherSupportResponseEntity(
      counters: counters?.toEntity() ?? const DispatcherSupportKpiEntity(),
      areaChips: areaChips?.map((c) => c.toEntity()).toList() ?? const [],
      issues: issues?.map((i) => i.toEntity()).toList() ?? const [],
      pagination:
          pagination?.toEntity() ?? const DispatcherSupportPaginationEntity(),
    );
  }
}

extension DispatcherSupportCountersDtoMapper on DispatcherSupportCountersDto {
  DispatcherSupportKpiEntity toEntity() {
    final open = openCount ?? missingCount ?? 0;
    final inProgress = inProgressCount ?? 0;
    final resolved = resolvedCount ?? 0;
    final total = totalCount ?? (open + inProgress + resolved);

    return DispatcherSupportKpiEntity(
      currentArea: currentArea ?? '',
      openCount: open,
      inProgressCount: inProgress,
      resolvedCount: resolved,
      totalCount: total,
    );
  }
}

extension DispatcherSupportAreaChipDtoMapper on DispatcherSupportAreaChipDto {
  DispatcherSupportAreaChipEntity toEntity() {
    return DispatcherSupportAreaChipEntity(
      areaKey: areaKey ?? key ?? '',
      displayName: displayName ?? name ?? '',
      count: count ?? 0,
    );
  }
}

extension DispatcherSupportPaginationDtoMapper
    on DispatcherSupportPaginationDto {
  DispatcherSupportPaginationEntity toEntity() {
    final pageNum = pageNumber ?? page ?? 1;
    final size = pageSize ?? this.size ?? 20;
    final total = totalCount ?? totalItems ?? 0;
    final pages = totalPages ?? (total > 0 ? ((total + size - 1) ~/ size) : 1);
    final hasNext = hasNextPage ?? (pageNum < pages);
    final hasPrev = hasPreviousPage ?? (pageNum > 1);

    return DispatcherSupportPaginationEntity(
      pageNumber: pageNum,
      pageSize: size,
      totalCount: total,
      totalPages: pages,
      hasNextPage: hasNext,
      hasPreviousPage: hasPrev,
    );
  }
}

extension DispatcherSupportIssueDtoMapper on DispatcherSupportIssueDto {
  DispatcherSupportIssueEntity toEntity() {
    final resolvedId = id ?? issueId ?? '';
    final resolvedBoxCode = boxCode ?? issueCode ?? '';
    final resolvedCategory = issueCategory ?? badgeText ?? '';
    final resolvedTimeAgo = timeAgo ?? reportedTimeText ?? '';
    final resolvedVehicle = vehicleInfo ?? vehicleText ?? '';

    final resolvedColor =
        _parseColor(issueCategoryColor) ??
        _parseColor(badgeColor) ??
        _parseColor(categoryColor);

    final resolvedPriorityColor = _parseColor(priorityColor);

    final resolvedStatus = _mapStatus(status);
    final resolvedIssueType = _mapIssueType(
      category: resolvedCategory,
      title: title,
    );

    DateTime? parsedReportedAtUtc;
    if (reportedAtUtc != null && reportedAtUtc!.isNotEmpty) {
      parsedReportedAtUtc = DateTime.tryParse(reportedAtUtc!)?.toUtc();
    }

    return DispatcherSupportIssueEntity(
      id: resolvedId,
      boxCode: resolvedBoxCode,
      title: title ?? '',
      issueCategory: resolvedCategory,
      categoryLabel: categoryLabel ?? badgeLabel,
      categoryColor: resolvedColor,
      timeAgo: resolvedTimeAgo,
      reportedAtUtc: parsedReportedAtUtc,
      driverId: driverId ?? '',
      driverCode: driverCode ?? '',
      driverName: driverName ?? '',
      driverAvatar: driverAvatar ?? '',
      driverPhone: driverPhone ?? '',
      area: area ?? '',
      vehicleInfo: resolvedVehicle,
      vehicleModel: vehicleModel ?? '',
      vehicleColor: vehicleColor ?? '',
      priority: priority ?? '',
      priorityLabel: priorityLabel ?? '',
      priorityColor: resolvedPriorityColor,
      status: resolvedStatus,
      statusLabel: statusLabel ?? '',
      issueType: resolvedIssueType,
      isDriverActive: isDriverActive ?? true,
    );
  }

  static DispatcherSupportStatus _mapStatus(String? status) {
    if (status == null) return DispatcherSupportStatus.open;
    final lower = status.toLowerCase();
    if (lower.contains('resolve')) {
      return DispatcherSupportStatus.resolved;
    }
    if (lower.contains('progress')) {
      return DispatcherSupportStatus.inProgress;
    }
    return DispatcherSupportStatus.open;
  }

  static DispatcherSupportIssueType _mapIssueType({
    required String category,
    String? title,
  }) {
    final combined = '${category.toLowerCase()} ${title?.toLowerCase() ?? ''}';
    if (combined.contains('delay') || combined.contains('late')) {
      return DispatcherSupportIssueType.severeDelay;
    }
    if (combined.contains('box') || combined.contains('damag')) {
      return DispatcherSupportIssueType.damagedBox;
    }
    if (combined.contains('unavail') || combined.contains('customer')) {
      return DispatcherSupportIssueType.customerUnavailable;
    }
    if (combined.contains('address') || combined.contains('locat')) {
      return DispatcherSupportIssueType.addressProblem;
    }
    return DispatcherSupportIssueType.unknown;
  }

  static int? _parseColor(Object? colorValue) {
    if (colorValue == null) return null;
    if (colorValue is int) return colorValue;
    if (colorValue is String) {
      final str = colorValue.trim();
      if (str.isEmpty) return null;

      // Check named colors
      final lower = str.toLowerCase();
      switch (lower) {
        case 'error':
        case 'red':
        case 'danger':
          return 0xFFF44336;
        case 'warning':
        case 'orange':
        case 'secondary':
        case 'amber':
          return 0xFFFF9800;
        case 'info':
        case 'blue':
          return 0xFF2196F3;
        case 'success':
        case 'green':
        case 'tertiary':
          return 0xFF4CAF50;
        case 'primary':
          return 0xFFFE8C00;
      }

      // Check hex format: #RRGGBB, #AARRGGBB, 0xRRGGBB, RRGGBB
      String hex = str;
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      } else if (hex.startsWith('0x') || hex.startsWith('0X')) {
        hex = hex.substring(2);
      }

      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      if (hex.length == 8) {
        return int.tryParse(hex, radix: 16);
      }
    }
    return null;
  }
}
