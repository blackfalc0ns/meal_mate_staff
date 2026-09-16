import 'dispatcher_driver_status.dart';

class DispatcherDriverEntity {
  const DispatcherDriverEntity({
    required this.id,
    required this.name,
    required this.rating,
    required this.status,
    required this.area,
    required this.currentOrdersCount,
    required this.completedOrdersTodayCount,
    required this.distanceKm,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final double rating;
  final DispatcherDriverStatus status;
  final String area;
  final int currentOrdersCount;
  final int completedOrdersTodayCount;
  final double distanceKm;
  final String? avatarUrl;

  bool get isAvailable => status == DispatcherDriverStatus.available;
}
