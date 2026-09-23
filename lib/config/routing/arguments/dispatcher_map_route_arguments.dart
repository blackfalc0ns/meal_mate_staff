class DispatcherMapRouteArgs {
  const DispatcherMapRouteArgs({
    this.areaKey,
    this.areaName,
    this.focusDriverId,
  });

  final String? areaKey;
  final String? areaName;
  final String? focusDriverId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherMapRouteArgs &&
          runtimeType == other.runtimeType &&
          areaKey == other.areaKey &&
          areaName == other.areaName &&
          focusDriverId == other.focusDriverId;

  @override
  int get hashCode => Object.hash(areaKey, areaName, focusDriverId);

  @override
  String toString() =>
      'DispatcherMapRouteArgs(areaKey: $areaKey, areaName: $areaName, focusDriverId: $focusDriverId)';
}
