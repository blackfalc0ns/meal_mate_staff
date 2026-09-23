class DriverDailySummaryEntity {
  const DriverDailySummaryEntity({
    required this.approxKm,
    required this.avgDelayMinutes,
    required this.failedDeliveryCount,
    required this.deliveredCount,
  });

  final int approxKm;
  final int avgDelayMinutes;
  final int failedDeliveryCount;
  final int deliveredCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverDailySummaryEntity &&
          runtimeType == other.runtimeType &&
          approxKm == other.approxKm &&
          avgDelayMinutes == other.avgDelayMinutes &&
          failedDeliveryCount == other.failedDeliveryCount &&
          deliveredCount == other.deliveredCount;

  @override
  int get hashCode => Object.hash(
    approxKm,
    avgDelayMinutes,
    failedDeliveryCount,
    deliveredCount,
  );
}
