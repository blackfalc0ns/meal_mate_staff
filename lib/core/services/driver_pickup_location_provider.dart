class DriverPickupCoordinates {
  DriverPickupCoordinates({required this.latitude, required this.longitude}) {
    final valid =
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
    if (!valid) {
      throw ArgumentError('Invalid pickup coordinates');
    }
  }

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverPickupCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() =>
      'DriverPickupCoordinates(lat: $latitude, lng: $longitude)';
}

abstract interface class DriverPickupLocationProvider {
  Future<DriverPickupCoordinates> getCurrentCoordinates();
}

class DefaultDriverPickupLocationProvider
    implements DriverPickupLocationProvider {
  const DefaultDriverPickupLocationProvider();

  @override
  Future<DriverPickupCoordinates> getCurrentCoordinates() async {
    return DriverPickupCoordinates(latitude: 29.3375, longitude: 48.0280);
  }
}

class GeolocatorDriverPickupLocationProvider
    implements DriverPickupLocationProvider {
  GeolocatorDriverPickupLocationProvider({this.locationService});

  final dynamic locationService;

  @override
  Future<DriverPickupCoordinates> getCurrentCoordinates() async {
    try {
      if (locationService != null) {
        final pos = await locationService.getCurrentPosition();
        if (pos != null && pos.latitude != 0 && pos.longitude != 0) {
          return DriverPickupCoordinates(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
        }
      }
    } catch (_) {}
    return const DefaultDriverPickupLocationProvider().getCurrentCoordinates();
  }
}
