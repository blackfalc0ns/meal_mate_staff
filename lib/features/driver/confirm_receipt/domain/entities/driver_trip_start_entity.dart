class DriverTripStartEntity {
  const DriverTripStartEntity({
    required this.tripId,
    required this.tripCode,
    this.startedAtUtc,
    required this.status,
    required this.statusText,
    required this.activeRouteId,
    this.message,
  });

  final String tripId;
  final String tripCode;
  final DateTime? startedAtUtc;
  final String status;
  final String statusText;
  final String activeRouteId;
  final String? message;
}
