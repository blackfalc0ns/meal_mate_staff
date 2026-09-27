import 'dispatcher_driver_status_item_entity.dart';
import 'dispatcher_drivers_pagination_entity.dart';
import 'dispatcher_drivers_status_kpis_entity.dart';

class DispatcherDriversStatusSummaryEntity {
  const DispatcherDriversStatusSummaryEntity({
    required this.counts,
    required this.items,
    this.pagination = const DispatcherDriversPaginationEntity(),
    this.restaurantName = '',
    this.role = '',
  });

  final DispatcherDriversStatusKpisEntity counts;
  final List<DispatcherDriverStatusItemEntity> items;
  final DispatcherDriversPaginationEntity pagination;
  final String restaurantName;
  final String role;

  // Backward compatibility convenience getters
  DispatcherDriversStatusKpisEntity get kpis => counts;
  List<DispatcherDriverStatusItemEntity> get drivers => items;

  DispatcherDriversStatusSummaryEntity copyWith({
    DispatcherDriversStatusKpisEntity? counts,
    List<DispatcherDriverStatusItemEntity>? items,
    DispatcherDriversPaginationEntity? pagination,
    String? restaurantName,
    String? role,
  }) {
    return DispatcherDriversStatusSummaryEntity(
      counts: counts ?? this.counts,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      restaurantName: restaurantName ?? this.restaurantName,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversStatusSummaryEntity &&
          runtimeType == other.runtimeType &&
          counts == other.counts &&
          pagination == other.pagination &&
          restaurantName == other.restaurantName &&
          role == other.role;

  @override
  int get hashCode => Object.hash(counts, pagination, restaurantName, role);
}
