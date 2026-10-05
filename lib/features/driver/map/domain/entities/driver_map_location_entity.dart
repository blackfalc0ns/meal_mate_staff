class DriverMapLocationEntity {
  const DriverMapLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
    this.recordedAtUtc,
    this.isStale = false,
    this.heading,
  });

  final double latitude;
  final double longitude;
  final String label;
  final String source; // 'tracking', 'shift_start', 'trip_stop'
  final DateTime? recordedAtUtc;
  final bool isStale;
  final double? heading;
}
