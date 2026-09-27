class DispatcherDriverPerformanceEntity {
  const DispatcherDriverPerformanceEntity({
    this.totalOrders = 0,
    this.averageRating = 0.0,
    this.commitmentRatePercent = 0,
    this.violationsCount = 0,
    this.acceptanceRate,
    this.onTimeRate,
    this.averageDeliveryMinutes,
    this.totalDeliveries,
  });

  final int totalOrders;
  final double averageRating;
  final int commitmentRatePercent;
  final int violationsCount;
  final double? acceptanceRate;
  final double? onTimeRate;
  final int? averageDeliveryMinutes;
  final int? totalDeliveries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverPerformanceEntity &&
          runtimeType == other.runtimeType &&
          totalOrders == other.totalOrders &&
          averageRating == other.averageRating &&
          commitmentRatePercent == other.commitmentRatePercent &&
          violationsCount == other.violationsCount &&
          acceptanceRate == other.acceptanceRate &&
          onTimeRate == other.onTimeRate &&
          averageDeliveryMinutes == other.averageDeliveryMinutes &&
          totalDeliveries == other.totalDeliveries;

  @override
  int get hashCode => Object.hash(
    totalOrders,
    averageRating,
    commitmentRatePercent,
    violationsCount,
    acceptanceRate,
    onTimeRate,
    averageDeliveryMinutes,
    totalDeliveries,
  );
}
