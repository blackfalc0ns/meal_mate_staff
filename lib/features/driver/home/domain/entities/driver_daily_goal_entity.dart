class DriverDailyGoalEntity {
  const DriverDailyGoalEntity({
    required this.completedOrders,
    required this.totalOrdersTarget,
    required this.performanceLevel,
  });

  final int completedOrders;
  final int totalOrdersTarget;
  final String performanceLevel;

  int get remainingOrders =>
      (totalOrdersTarget - completedOrders).clamp(0, totalOrdersTarget);

  double get progress => totalOrdersTarget > 0
      ? (completedOrders / totalOrdersTarget).clamp(0.0, 1.0)
      : 0.0;
}
