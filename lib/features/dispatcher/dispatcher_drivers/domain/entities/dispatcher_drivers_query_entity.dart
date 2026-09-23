import 'dispatcher_driver_view_mode.dart';

class DispatcherDriversQueryEntity {
  const DispatcherDriversQueryEntity({
    this.view = DispatcherDriverViewMode.byArea,
    this.areaKey,
    this.areaName,
    this.boxId,
  });

  final DispatcherDriverViewMode view;
  final String? areaKey;
  final String? areaName;
  final String? boxId;

  DispatcherDriversQueryEntity copyWith({
    DispatcherDriverViewMode? view,
    String? areaKey,
    String? areaName,
    String? boxId,
    bool clearArea = false,
  }) {
    return DispatcherDriversQueryEntity(
      view: view ?? this.view,
      areaKey: clearArea ? null : (areaKey ?? this.areaKey),
      areaName: clearArea ? null : (areaName ?? this.areaName),
      boxId: boxId ?? this.boxId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversQueryEntity &&
          runtimeType == other.runtimeType &&
          view == other.view &&
          areaKey == other.areaKey &&
          areaName == other.areaName &&
          boxId == other.boxId;

  @override
  int get hashCode =>
      view.hashCode ^ areaKey.hashCode ^ areaName.hashCode ^ boxId.hashCode;
}
