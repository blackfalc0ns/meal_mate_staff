class DriverDeliverResultEntity {
  const DriverDeliverResultEntity({
    required this.boxId,
    required this.deliveredAtUtc,
    this.tripId,
    this.isTripCompleted,
    this.remainingStopsCount,
    this.driverId,
    this.isFirstDelivery,
  });

  final String boxId;
  final DateTime deliveredAtUtc;
  final String? tripId;
  final bool? isTripCompleted;
  final int? remainingStopsCount;
  final String? driverId;
  final bool? isFirstDelivery;
}
