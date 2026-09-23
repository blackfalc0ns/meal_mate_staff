class OperationsCountersEntity {
  const OperationsCountersEntity({
    this.allCount = 0,
    this.completedCount = 0,
    this.cancelledCount = 0,
    this.failedCount = 0,
    this.reassignedCount = 0,
  });

  final int allCount;
  final int completedCount;
  final int cancelledCount;
  final int failedCount;
  final int reassignedCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsCountersEntity &&
          runtimeType == other.runtimeType &&
          allCount == other.allCount &&
          completedCount == other.completedCount &&
          cancelledCount == other.cancelledCount &&
          failedCount == other.failedCount &&
          reassignedCount == other.reassignedCount;

  @override
  int get hashCode => Object.hash(
    allCount,
    completedCount,
    cancelledCount,
    failedCount,
    reassignedCount,
  );
}
