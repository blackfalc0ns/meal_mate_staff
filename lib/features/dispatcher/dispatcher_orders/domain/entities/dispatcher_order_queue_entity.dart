import 'dispatcher_order_entity.dart';

class DispatcherOrderQueueRestaurantEntity {
  const DispatcherOrderQueueRestaurantEntity({
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

class DispatcherOrderQueueCountsEntity {
  const DispatcherOrderQueueCountsEntity({
    this.totalCount = 0,
    this.pendingCount = 0,
    this.assignedCount = 0,
    this.inDeliveryCount = 0,
    this.issuesCount = 0,
  });

  final int totalCount;
  final int pendingCount;
  final int assignedCount;
  final int inDeliveryCount;
  final int issuesCount;
}

class DispatcherOrderQueueEntity {
  const DispatcherOrderQueueEntity({
    required this.restaurant,
    required this.counts,
    required this.boxes,
  });

  final DispatcherOrderQueueRestaurantEntity restaurant;
  final DispatcherOrderQueueCountsEntity counts;
  final List<DispatcherOrderEntity> boxes;
}
