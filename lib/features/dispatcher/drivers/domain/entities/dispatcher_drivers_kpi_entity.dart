class DispatcherDriversKpiEntity {
  const DispatcherDriversKpiEntity({
    required this.totalDrivers,
    required this.availableDrivers,
    required this.busyNow,
  });

  final int totalDrivers;
  final int availableDrivers;
  final int busyNow;
}
