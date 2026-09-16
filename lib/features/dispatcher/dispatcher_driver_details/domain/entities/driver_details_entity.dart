import 'driver_active_box_entity.dart';

class DriverDetailsEntity {
  const DriverDetailsEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.isAvailable,
    required this.lastUpdate,
    required this.currentBoxesCount,
    required this.deliveredTodayCount,
    required this.avgDelayMinutes,
    required this.performanceRating,
    required this.locationStatus,
    required this.locationTimeAgoMinutes,
    required this.locationStreet,
    required this.locationArea,
    required this.approxKm,
    required this.failedDeliveryCount,
    required this.activeBoxes,
  });

  final String id;
  final String name;
  final String phone;
  final bool isAvailable;
  final String lastUpdate;
  final int currentBoxesCount;
  final int deliveredTodayCount;
  final int avgDelayMinutes;
  final double performanceRating;
  final String locationStatus;
  final int locationTimeAgoMinutes;
  final String locationStreet;
  final String locationArea;
  final int approxKm;
  final int failedDeliveryCount;
  final List<DriverActiveBoxEntity> activeBoxes;
}
