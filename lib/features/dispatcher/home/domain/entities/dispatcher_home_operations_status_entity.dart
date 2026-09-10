class DispatcherHomeOperationsStatusEntity {
  const DispatcherHomeOperationsStatusEntity({
    required this.completionRate,
    required this.deliveredCount,
    required this.deliveredLabel,
    required this.inDeliveryCount,
    required this.inDeliveryLabel,
    required this.pendingCount,
    required this.pendingLabel,
    required this.cancelledCount,
    required this.cancelledLabel,
  });

  final int completionRate;
  final int deliveredCount;
  final String deliveredLabel;
  final int inDeliveryCount;
  final String inDeliveryLabel;
  final int pendingCount;
  final String pendingLabel;
  final int cancelledCount;
  final String cancelledLabel;
}
