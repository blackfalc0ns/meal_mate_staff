import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_drivers_roster_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDriversRosterResponseDto {
  const DispatcherDriversRosterResponseDto({
    this.counts,
    this.selectedView,
    this.selectedArea,
    this.selectedAreaKey,
    this.sectionTitle,
    this.areas,
    this.drivers,
  });

  factory DispatcherDriversRosterResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriversRosterResponseDtoFromJson(json);

  final DispatcherDriversCountsDto? counts;
  final String? selectedView;
  final String? selectedArea;
  final String? selectedAreaKey;
  final String? sectionTitle;
  final List<DispatcherDriverAreaDto>? areas;
  final List<DispatcherDriverItemDto>? drivers;
}

@JsonSerializable(createToJson: false)
class DispatcherDriversCountsDto {
  const DispatcherDriversCountsDto({
    this.totalCount,
    this.availableCount,
    this.busyCount,
  });

  factory DispatcherDriversCountsDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriversCountsDtoFromJson(json);

  final int? totalCount;
  final int? availableCount;
  final int? busyCount;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverAreaDto {
  const DispatcherDriverAreaDto({
    this.name,
    this.areaKey,
    this.driverCount,
    this.isSelected,
  });

  factory DispatcherDriverAreaDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverAreaDtoFromJson(json);

  final String? name;
  final String? areaKey;
  final int? driverCount;
  final bool? isSelected;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverItemDto {
  const DispatcherDriverItemDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.avatarUrl,
    this.rating,
    this.status,
    this.statusText,
    this.statusDotColor,
    this.isAvailableForSelection,
    this.activeOrdersCount,
    this.activeOrdersText,
    this.completedOrdersTodayCount,
    this.completedOrdersText,
    this.distanceKm,
    this.distanceText,
    this.currentZoneName,
    this.currentZoneKey,
  });

  factory DispatcherDriverItemDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverItemDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? avatarUrl;
  final double? rating;
  final String? status;
  final String? statusText;
  final String? statusDotColor;
  final bool? isAvailableForSelection;
  final int? activeOrdersCount;
  final String? activeOrdersText;
  final int? completedOrdersTodayCount;
  final String? completedOrdersText;
  final double? distanceKm;
  final String? distanceText;
  final String? currentZoneName;
  final String? currentZoneKey;
}
