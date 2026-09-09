import 'dispatcher_order_priority.dart';

class DispatcherOrderEntity {
  const DispatcherOrderEntity({
    required this.id,
    required this.boxCode,
    required this.priority,
    required this.area,
    required this.deliveryTimeWindow,
    required this.mealsCount,
    required this.distanceKm,
    required this.suggestedDriverName,
    this.isLeastLoaded = false,
  });

  final String id;
  final String boxCode;
  final DispatcherOrderPriority priority;
  final String area;
  final String deliveryTimeWindow;
  final int mealsCount;
  final String distanceKm;
  final String suggestedDriverName;
  final bool isLeastLoaded;
}
