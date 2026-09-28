import 'driver_current_order_entity.dart';
import 'driver_daily_goal_entity.dart';
import 'driver_daily_performance_entity.dart';
import 'driver_daily_summary_entity.dart';

class DriverActiveHomeEntity {
  const DriverActiveHomeEntity({
    required this.isInDelivery,
    required this.currentLocation,
    required this.goal,
    required this.currentOrder,
    required this.summary,
    required this.performance,
  });

  final bool isInDelivery;
  final String currentLocation;
  final DriverDailyGoalEntity goal;
  final DriverCurrentOrderEntity currentOrder;
  final DriverDailySummaryEntity summary;
  final DriverDailyPerformanceEntity performance;
}
