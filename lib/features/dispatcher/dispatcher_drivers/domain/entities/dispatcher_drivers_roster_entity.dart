import 'package:flutter/foundation.dart';

import 'dispatcher_driver_area_entity.dart';
import 'dispatcher_driver_entity.dart';
import 'dispatcher_driver_view_mode.dart';
import 'dispatcher_drivers_kpi_entity.dart';

class DispatcherDriversRosterEntity {
  const DispatcherDriversRosterEntity({
    required this.counts,
    required this.selectedView,
    required this.selectedAreaKey,
    required this.selectedAreaName,
    required this.sectionTitle,
    required this.areas,
    required this.drivers,
  });

  final DispatcherDriversKpiEntity counts;
  final DispatcherDriverViewMode selectedView;
  final String? selectedAreaKey;
  final String? selectedAreaName;
  final String sectionTitle;
  final List<DispatcherDriverAreaEntity> areas;
  final List<DispatcherDriverEntity> drivers;

  DispatcherDriversRosterEntity copyWith({
    DispatcherDriversKpiEntity? counts,
    DispatcherDriverViewMode? selectedView,
    String? selectedAreaKey,
    String? selectedAreaName,
    String? sectionTitle,
    List<DispatcherDriverAreaEntity>? areas,
    List<DispatcherDriverEntity>? drivers,
  }) {
    return DispatcherDriversRosterEntity(
      counts: counts ?? this.counts,
      selectedView: selectedView ?? this.selectedView,
      selectedAreaKey: selectedAreaKey ?? this.selectedAreaKey,
      selectedAreaName: selectedAreaName ?? this.selectedAreaName,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      areas: areas ?? this.areas,
      drivers: drivers ?? this.drivers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversRosterEntity &&
          runtimeType == other.runtimeType &&
          counts == other.counts &&
          selectedView == other.selectedView &&
          selectedAreaKey == other.selectedAreaKey &&
          selectedAreaName == other.selectedAreaName &&
          sectionTitle == other.sectionTitle &&
          listEquals(areas, other.areas) &&
          listEquals(drivers, other.drivers);

  @override
  int get hashCode =>
      counts.hashCode ^
      selectedView.hashCode ^
      selectedAreaKey.hashCode ^
      selectedAreaName.hashCode ^
      sectionTitle.hashCode ^
      Object.hashAll(areas) ^
      Object.hashAll(drivers);
}
