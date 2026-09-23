class DriverLocationPointEntity {
  const DriverLocationPointEntity({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverLocationPointEntity &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'DriverLocationPointEntity(lat: $latitude, lng: $longitude)';
}
