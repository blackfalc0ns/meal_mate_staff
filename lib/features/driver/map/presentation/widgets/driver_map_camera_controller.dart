import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMapCameraController {
  const DriverMapCameraController();

  static const LatLng defaultKuwaitCenter = LatLng(29.3759, 47.9774);

  CameraUpdate calculateBoundsUpdate(
    List<LatLng> points, {
    double padding = 50.0,
  }) {
    if (points.isEmpty) {
      return CameraUpdate.newLatLngZoom(defaultKuwaitCenter, 11.0);
    }

    if (points.length == 1) {
      return CameraUpdate.newLatLngZoom(points.first, 15.0);
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    // Check if duplicate identical points
    if ((maxLat - minLat).abs() < 1e-6 && (maxLng - minLng).abs() < 1e-6) {
      return CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 15.0);
    }

    return CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      padding,
    );
  }
}
