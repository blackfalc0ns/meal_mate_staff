class ReassignmentDeliveryContextEntity {
  const ReassignmentDeliveryContextEntity({
    required this.boxId,
    this.boxCode,
    this.tripId,
    required this.isPickedUp,
    this.driverLatitude,
    this.driverLongitude,
  });

  final String boxId;
  final String? boxCode;
  final String? tripId;
  final bool isPickedUp;
  final double? driverLatitude;
  final double? driverLongitude;

  ReassignmentDeliveryContextEntity copyWith({
    String? boxId,
    String? boxCode,
    String? tripId,
    bool? isPickedUp,
    double? driverLatitude,
    double? driverLongitude,
  }) {
    return ReassignmentDeliveryContextEntity(
      boxId: boxId ?? this.boxId,
      boxCode: boxCode ?? this.boxCode,
      tripId: tripId ?? this.tripId,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
    );
  }
}
