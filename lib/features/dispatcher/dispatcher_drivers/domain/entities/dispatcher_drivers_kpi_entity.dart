class DispatcherDriversKpiEntity {
  const DispatcherDriversKpiEntity({
    int? totalCount,
    int? availableCount,
    int? busyCount,
    int? totalDrivers,
    int? availableDrivers,
    int? busyNow,
  }) : totalCount = totalCount ?? totalDrivers ?? 0,
       availableCount = availableCount ?? availableDrivers ?? 0,
       busyCount = busyCount ?? busyNow ?? 0;

  final int totalCount;
  final int availableCount;
  final int busyCount;

  int get totalDrivers => totalCount;
  int get availableDrivers => availableCount;
  int get busyNow => busyCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversKpiEntity &&
          runtimeType == other.runtimeType &&
          totalCount == other.totalCount &&
          availableCount == other.availableCount &&
          busyCount == other.busyCount;

  @override
  int get hashCode =>
      totalCount.hashCode ^ availableCount.hashCode ^ busyCount.hashCode;
}
