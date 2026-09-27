class DispatcherDriverPerformanceEntity {
  const DispatcherDriverPerformanceEntity({
    required this.totalOrders,
    required this.averageRating,
    required this.commitmentRatePercent,
    required this.violationsCount,
  });

  final int totalOrders;
  final double averageRating;
  final int commitmentRatePercent;
  final int violationsCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverPerformanceEntity &&
          runtimeType == other.runtimeType &&
          totalOrders == other.totalOrders &&
          averageRating == other.averageRating &&
          commitmentRatePercent == other.commitmentRatePercent &&
          violationsCount == other.violationsCount;

  @override
  int get hashCode => Object.hash(
    totalOrders,
    averageRating,
    commitmentRatePercent,
    violationsCount,
  );
}
