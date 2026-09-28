class DriverDailySummaryEntity {
  const DriverDailySummaryEntity({
    required this.incompleteCount,
    required this.inDeliveryCount,
    required this.deliveredCount,
    required this.totalOrdersCount,
  });

  final int incompleteCount;
  final int inDeliveryCount;
  final int deliveredCount;
  final int totalOrdersCount;
}
