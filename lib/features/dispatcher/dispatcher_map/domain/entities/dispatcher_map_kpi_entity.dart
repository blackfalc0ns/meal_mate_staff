class DispatcherMapKpiEntity {
  const DispatcherMapKpiEntity({
    required this.activeDriversCount,
    required this.inDeliveryCount,
    required this.pausedCount,
    required this.issuesCount,
  });

  final int activeDriversCount;
  final int inDeliveryCount;
  final int pausedCount;
  final int issuesCount;
}
