class DriverLiveLocationSample {
  const DriverLiveLocationSample({
    required this.latitude,
    required this.longitude,
    required this.recordedAtUtc,
    this.heading,
    this.speedKmh,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAtUtc;
  final double? heading;
  final double? speedKmh;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverLiveLocationSample &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          recordedAtUtc == other.recordedAtUtc &&
          heading == other.heading &&
          speedKmh == other.speedKmh;

  @override
  int get hashCode => Object.hash(
        latitude,
        longitude,
        recordedAtUtc,
        heading,
        speedKmh,
      );
}
