import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActiveDeliveryLocationEntity {
  const ActiveDeliveryLocationEntity({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.speed = 0.0,
  });

  final double latitude;
  final double longitude;
  final double heading;
  final double speed;

  LatLng get toLatLng => LatLng(latitude, longitude);

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      !(latitude == 0.0 && longitude == 0.0);

  ActiveDeliveryLocationEntity copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
  }) {
    return ActiveDeliveryLocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
    );
  }
}
