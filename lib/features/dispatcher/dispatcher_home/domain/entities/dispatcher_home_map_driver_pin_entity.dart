enum DispatcherHomePinStatus {
  enRouteToCustomer,
  inDelivery,
  onBreak,
  available,
  unknown,
}

class DispatcherHomeMapDriverPinEntity {
  const DispatcherHomeMapDriverPinEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.plateNumber,
    required this.statusText,
    required this.status,
    required this.avatarUrl,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speedKmh,
    required this.updatedAtUtc,
    this.activeOrderId,
    this.customerAddress,
  });

  final String id;
  final String fullName;
  final String phone;
  final String plateNumber;
  final String statusText;
  final DispatcherHomePinStatus status;
  final String avatarUrl;
  final double latitude;
  final double longitude;
  final double heading;
  final double speedKmh;
  final String? activeOrderId;
  final String? customerAddress;
  final DateTime? updatedAtUtc;
}
