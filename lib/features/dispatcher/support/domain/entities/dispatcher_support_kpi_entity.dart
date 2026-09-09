class DispatcherSupportKpiEntity {
  const DispatcherSupportKpiEntity({
    required this.currentArea,
    required this.missingCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  final String currentArea;
  final int missingCount;
  final int inProgressCount;
  final int resolvedCount;
}
