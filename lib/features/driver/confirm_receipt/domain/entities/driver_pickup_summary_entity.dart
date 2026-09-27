class DriverPickupSummaryEntity {
  const DriverPickupSummaryEntity({
    required this.tripId,
    required this.tripCode,
    required this.driverId,
    required this.driverName,
    required this.assignedBoxesCount,
    required this.validatedBoxesCount,
    required this.receivedBoxesCount,
    required this.totalBoxesCount,
    required this.pickedUpBoxesCount,
    required this.allBoxesPickedUp,
    required this.canStartTrip,
    required this.boxes,
    this.message,
  });

  final String tripId;
  final String tripCode;
  final String driverId;
  final String driverName;
  final int assignedBoxesCount;
  final int validatedBoxesCount;
  final int receivedBoxesCount;
  final int totalBoxesCount;
  final int pickedUpBoxesCount;
  final bool allBoxesPickedUp;
  final bool canStartTrip;
  final List<DriverPickupSummaryBoxEntity> boxes;
  final String? message;
}

class DriverPickupSummaryBoxEntity {
  const DriverPickupSummaryBoxEntity({
    required this.boxId,
    required this.boxCode,
    required this.customerName,
    required this.deliveryZone,
    required this.mealsCount,
    required this.status,
    required this.statusText,
    required this.isReceived,
    this.conditionPhotoStorageKey,
  });

  final String boxId;
  final String boxCode;
  final String customerName;
  final String deliveryZone;
  final int mealsCount;
  final String status;
  final String statusText;
  final bool isReceived;
  final String? conditionPhotoStorageKey;
}
