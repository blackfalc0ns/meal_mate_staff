class DispatcherSupportKpiEntity {
  const DispatcherSupportKpiEntity({
    this.currentArea = '',
    int? openCount,
    int? missingCount,
    this.inProgressCount = 0,
    this.resolvedCount = 0,
    this.totalCount = 0,
  }) : openCount = openCount ?? missingCount ?? 0;

  final String currentArea;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int totalCount;

  int get missingCount => openCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherSupportKpiEntity &&
          runtimeType == other.runtimeType &&
          currentArea == other.currentArea &&
          openCount == other.openCount &&
          inProgressCount == other.inProgressCount &&
          resolvedCount == other.resolvedCount &&
          totalCount == other.totalCount;

  @override
  int get hashCode => Object.hash(
    currentArea,
    openCount,
    inProgressCount,
    resolvedCount,
    totalCount,
  );
}
