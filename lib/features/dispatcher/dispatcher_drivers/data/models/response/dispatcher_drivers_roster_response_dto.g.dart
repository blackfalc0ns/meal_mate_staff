// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_drivers_roster_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherDriversRosterResponseDto _$DispatcherDriversRosterResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriversRosterResponseDto(
  counts: json['counts'] == null
      ? null
      : DispatcherDriversCountsDto.fromJson(
          json['counts'] as Map<String, dynamic>,
        ),
  selectedView: json['selectedView'] as String?,
  selectedArea: json['selectedArea'] as String?,
  selectedAreaKey: json['selectedAreaKey'] as String?,
  sectionTitle: json['sectionTitle'] as String?,
  areas: (json['areas'] as List<dynamic>?)
      ?.map((e) => DispatcherDriverAreaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  drivers: (json['drivers'] as List<dynamic>?)
      ?.map((e) => DispatcherDriverItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

DispatcherDriversCountsDto _$DispatcherDriversCountsDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriversCountsDto(
  totalCount: (json['totalCount'] as num?)?.toInt(),
  availableCount: (json['availableCount'] as num?)?.toInt(),
  busyCount: (json['busyCount'] as num?)?.toInt(),
);

DispatcherDriverAreaDto _$DispatcherDriverAreaDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverAreaDto(
  name: json['name'] as String?,
  areaKey: json['areaKey'] as String?,
  driverCount: (json['driverCount'] as num?)?.toInt(),
  isSelected: json['isSelected'] as bool?,
);

DispatcherDriverItemDto _$DispatcherDriverItemDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverItemDto(
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  statusDotColor: json['statusDotColor'] as String?,
  isAvailableForSelection: json['isAvailableForSelection'] as bool?,
  activeOrdersCount: (json['activeOrdersCount'] as num?)?.toInt(),
  activeOrdersText: json['activeOrdersText'] as String?,
  completedOrdersTodayCount: (json['completedOrdersTodayCount'] as num?)
      ?.toInt(),
  completedOrdersText: json['completedOrdersText'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  distanceText: json['distanceText'] as String?,
  currentZoneName: json['currentZoneName'] as String?,
  currentZoneKey: json['currentZoneKey'] as String?,
);
