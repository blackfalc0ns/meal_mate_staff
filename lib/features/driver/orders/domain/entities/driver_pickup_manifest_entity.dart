import 'driver_assigned_box_entity.dart';

class DriverPickupManifestEntity {
  const DriverPickupManifestEntity({
    required this.tripId,
    required this.tripCode,
    required this.driverId,
    required this.driverName,
    required this.totalBoxesCount,
    required this.totalMealsCount,
    required this.pendingScanBoxesCount,
    required this.pickedUpBoxesCount,
    required this.allBoxesPickedUp,
    required this.canStartTrip,
    required this.boxes,
  });

  final String tripId;
  final String tripCode;
  final String driverId;
  final String driverName;
  final int totalBoxesCount;
  final int totalMealsCount;
  final int pendingScanBoxesCount;
  final int pickedUpBoxesCount;
  final bool allBoxesPickedUp;
  final bool canStartTrip;
  final List<DriverAssignedBoxEntity> boxes;
}
