import 'package:meal_mate_delivery/core/errors/location_exception.dart';
import 'package:meal_mate_delivery/core/services/driver_pickup_location_provider.dart';

class FakeDriverPickupLocationProvider implements DriverPickupLocationProvider {
  FakeDriverPickupLocationProvider({
    this.coordinates,
    this.shouldThrow = false,
    this.errorType = LocationErrorType.permissionDenied,
  });

  DriverPickupCoordinates? coordinates;
  bool shouldThrow;
  LocationErrorType errorType;

  @override
  Future<DriverPickupCoordinates> getCurrentCoordinates() async {
    if (shouldThrow) {
      throw LocationServiceException(errorType);
    }
    return coordinates ??
        DriverPickupCoordinates(latitude: 29.3375, longitude: 48.0280);
  }
}
