import 'dart:math' as math;

import '../../domain/entities/assign_driver_request_entity.dart';
import '../../domain/entities/dispatcher_driver_area_entity.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import '../../domain/entities/dispatcher_driver_status.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';
import '../../domain/entities/dispatcher_drivers_kpi_entity.dart';
import '../../domain/entities/dispatcher_drivers_roster_entity.dart';
import '../../domain/entities/driver_assignment_result_entity.dart';
import '../models/request/assign_driver_request_dto.dart';
import '../models/response/dispatcher_drivers_roster_response_dto.dart';
import '../models/response/driver_assignment_response_dto.dart';

extension DispatcherDriversCountsDtoMapper on DispatcherDriversCountsDto? {
  DispatcherDriversKpiEntity toEntity() {
    return DispatcherDriversKpiEntity(
      totalCount: math.max(0, this?.totalCount ?? 0),
      availableCount: math.max(0, this?.availableCount ?? 0),
      busyCount: math.max(0, this?.busyCount ?? 0),
    );
  }
}

extension DispatcherDriverAreaDtoMapper on DispatcherDriverAreaDto {
  DispatcherDriverAreaEntity toEntity() {
    return DispatcherDriverAreaEntity(
      name: name ?? '',
      areaKey: areaKey ?? '',
      driverCount: math.max(0, driverCount ?? 0),
      isSelected: isSelected ?? false,
    );
  }
}

extension DispatcherDriverItemDtoMapper on DispatcherDriverItemDto {
  DispatcherDriverEntity toEntity() {
    return DispatcherDriverEntity(
      driverId: driverId ?? '',
      driverCode: driverCode ?? '',
      fullName: fullName ?? '',
      avatarUrl: avatarUrl,
      rating: (rating ?? 0.0).toDouble(),
      status: DispatcherDriverStatusX.fromApi(status),
      statusText: statusText,
      statusDotColor: statusDotColor,
      isAvailableForSelection: isAvailableForSelection ?? false,
      activeOrdersCount: math.max(0, activeOrdersCount ?? 0),
      activeOrdersText: activeOrdersText,
      completedOrdersTodayCount: math.max(0, completedOrdersTodayCount ?? 0),
      completedOrdersText: completedOrdersText,
      distanceKm: (distanceKm ?? 0.0).toDouble(),
      distanceText: distanceText,
      currentZoneName: currentZoneName ?? '',
      currentZoneKey: currentZoneKey,
    );
  }
}

extension DispatcherDriversRosterResponseDtoMapper
    on DispatcherDriversRosterResponseDto {
  DispatcherDriversRosterEntity toEntity() {
    return DispatcherDriversRosterEntity(
      counts: counts.toEntity(),
      selectedView: DispatcherDriverViewModeX.fromApi(selectedView),
      selectedAreaKey: selectedAreaKey,
      selectedAreaName: selectedArea ?? '',
      sectionTitle: sectionTitle ?? '',
      areas: areas?.map((a) => a.toEntity()).toList() ?? const [],
      drivers: drivers?.map((d) => d.toEntity()).toList() ?? const [],
    );
  }
}

extension AssignDriverRequestEntityMapper on AssignDriverRequestEntity {
  AssignDriverRequestDto toDto() {
    return AssignDriverRequestDto(driverId: driverId, notes: notes);
  }
}

extension DriverAssignmentResponseDtoMapper on DriverAssignmentResponseDto {
  DriverAssignmentResultEntity toEntity() {
    DateTime? parsedAssignedAt;
    if (assignedAt != null && assignedAt!.isNotEmpty) {
      parsedAssignedAt = DateTime.tryParse(assignedAt!)?.toUtc();
    }
    return DriverAssignmentResultEntity(
      success: success ?? true,
      message: message ?? '',
      assignedAt: parsedAssignedAt,
      boxId: boxId,
      driverId: driverId,
    );
  }
}
