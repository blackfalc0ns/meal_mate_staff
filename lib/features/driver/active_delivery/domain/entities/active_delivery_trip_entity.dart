import 'active_delivery_location_entity.dart';
import 'active_delivery_order_entity.dart';
import 'delivery_failure_reason_entity.dart';
import 'delivery_trip_status.dart';
import 'return_box_entity.dart';

class ActiveDeliveryTripEntity {
  const ActiveDeliveryTripEntity({
    required this.tripId,
    required this.order,
    required this.status,
    required this.driverLocation,
    required this.customerLocation,
    required this.restaurantLocation,
    required this.routePoints,
    required this.estimatedMinutes,
    required this.distanceKm,
    this.startedAt,
    this.arrivedAt,
    this.deliveredAt,
    this.failureReason,
    this.delayReason,
    this.returnBox,
  });

  final String tripId;
  final ActiveDeliveryOrderEntity order;
  final DeliveryTripStatus status;
  final ActiveDeliveryLocationEntity driverLocation;
  final ActiveDeliveryLocationEntity customerLocation;
  final ActiveDeliveryLocationEntity restaurantLocation;
  final List<ActiveDeliveryLocationEntity> routePoints;
  final int estimatedMinutes;
  final double distanceKm;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? deliveredAt;
  final DeliveryFailureReasonEntity? failureReason;
  final String? delayReason;
  final ReturnBoxEntity? returnBox;

  ActiveDeliveryTripEntity copyWith({
    String? tripId,
    ActiveDeliveryOrderEntity? order,
    DeliveryTripStatus? status,
    ActiveDeliveryLocationEntity? driverLocation,
    ActiveDeliveryLocationEntity? customerLocation,
    ActiveDeliveryLocationEntity? restaurantLocation,
    List<ActiveDeliveryLocationEntity>? routePoints,
    int? estimatedMinutes,
    double? distanceKm,
    DateTime? startedAt,
    DateTime? arrivedAt,
    DateTime? deliveredAt,
    DeliveryFailureReasonEntity? failureReason,
    String? delayReason,
    ReturnBoxEntity? returnBox,
  }) {
    return ActiveDeliveryTripEntity(
      tripId: tripId ?? this.tripId,
      order: order ?? this.order,
      status: status ?? this.status,
      driverLocation: driverLocation ?? this.driverLocation,
      customerLocation: customerLocation ?? this.customerLocation,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
      routePoints: routePoints ?? this.routePoints,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      startedAt: startedAt ?? this.startedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      failureReason: failureReason ?? this.failureReason,
      delayReason: delayReason ?? this.delayReason,
      returnBox: returnBox ?? this.returnBox,
    );
  }
}
