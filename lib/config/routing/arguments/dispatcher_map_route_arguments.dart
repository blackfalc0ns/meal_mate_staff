class DispatcherMapRouteArgs {
  const DispatcherMapRouteArgs({this.areaKey, this.areaName});

  final String? areaKey;
  final String? areaName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherMapRouteArgs &&
          runtimeType == other.runtimeType &&
          areaKey == other.areaKey &&
          areaName == other.areaName;

  @override
  int get hashCode => Object.hash(areaKey, areaName);

  @override
  String toString() =>
      'DispatcherMapRouteArgs(areaKey: $areaKey, areaName: $areaName)';
}
