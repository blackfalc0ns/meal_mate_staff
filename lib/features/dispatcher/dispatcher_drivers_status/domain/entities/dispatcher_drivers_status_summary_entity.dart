import 'dispatcher_driver_status_item_entity.dart';
import 'dispatcher_drivers_status_kpis_entity.dart';

class DispatcherDriversStatusSummaryEntity {
  const DispatcherDriversStatusSummaryEntity({
    required this.restaurantName,
    required this.role,
    required this.kpis,
    required this.drivers,
  });

  final String restaurantName;
  final String role;
  final DispatcherDriversStatusKpisEntity kpis;
  final List<DispatcherDriverStatusItemEntity> drivers;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversStatusSummaryEntity &&
          runtimeType == other.runtimeType &&
          restaurantName == other.restaurantName &&
          role == other.role &&
          kpis == other.kpis;

  @override
  int get hashCode => Object.hash(restaurantName, role, kpis);
}
