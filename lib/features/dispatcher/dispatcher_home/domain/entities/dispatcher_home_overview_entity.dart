import 'dispatcher_home_alert_entity.dart';
import 'dispatcher_home_area_summary_entity.dart';
import 'dispatcher_home_operations_status_entity.dart';
import 'dispatcher_home_top_driver_entity.dart';

class DispatcherHomeRestaurantEntity {
  const DispatcherHomeRestaurantEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.role,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String role;
}

class DispatcherHomeGreetingEntity {
  const DispatcherHomeGreetingEntity({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class DispatcherHomeKpisEntity {
  const DispatcherHomeKpisEntity({
    required this.totalOrdersToday,
    required this.inDeliveryCount,
    required this.pendingAssignmentCount,
    required this.activeIssuesCount,
  });

  final int totalOrdersToday;
  final int inDeliveryCount;
  final int pendingAssignmentCount;
  final int activeIssuesCount;
}

class DispatcherHomeOverviewEntity {
  const DispatcherHomeOverviewEntity({
    required this.restaurant,
    required this.greeting,
    required this.kpis,
    required this.operationsStatus,
    required this.topDrivers,
    required this.regions,
    required this.activeIssues,
  });

  final DispatcherHomeRestaurantEntity restaurant;
  final DispatcherHomeGreetingEntity greeting;
  final DispatcherHomeKpisEntity kpis;
  final DispatcherHomeOperationsStatusEntity operationsStatus;
  final List<DispatcherHomeTopDriverEntity> topDrivers;
  final List<DispatcherHomeAreaSummaryEntity> regions;
  final DispatcherHomeActiveIssuesEntity activeIssues;
}
