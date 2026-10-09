class DriverStartDeliveryResultEntity {
  const DriverStartDeliveryResultEntity({
    required this.boxId,
    required this.status,
    this.tripId,
    this.startedAtUtc,
    this.customerName,
    this.customerAddress,
    this.customerLatitude,
    this.customerLongitude,
    this.customerNotes,
    this.orderCode,
    this.boxCount,
    this.deliveryTimeSlot,
    this.navigationUrl,
  });

  final String boxId;
  final String status;
  final String? tripId;
  final DateTime? startedAtUtc;
  final String? customerName;
  final String? customerAddress;
  final double? customerLatitude;
  final double? customerLongitude;
  final String? customerNotes;
  final String? orderCode;
  final int? boxCount;
  final String? deliveryTimeSlot;
  final String? navigationUrl;
}
