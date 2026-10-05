import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMapPolylineDecoder {
  const DriverMapPolylineDecoder();

  static List<LatLng> decodePolyline(String? encodedPolyline, {String encoding = 'google_polyline5'}) {
    return const DriverMapPolylineDecoder().decode(encodedPolyline, encoding: encoding);
  }

  List<LatLng> decode(String? encodedPolyline, {String encoding = 'google_polyline5'}) {
    if (encodedPolyline == null) return const [];
    final trimmed = encodedPolyline.trim();
    if (trimmed.isEmpty || encoding != 'google_polyline5') return const [];

    final List<LatLng> points = [];
    int index = 0;
    final int len = trimmed.length;
    int lat = 0;
    int lng = 0;

    try {
      while (index < len) {
        int b;
        int shift = 0;
        int result = 0;
        do {
          b = trimmed.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = trimmed.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.add(LatLng(lat / 1E5, lng / 1E5));
      }
    } catch (_) {
      return const [];
    }

    return points;
  }
}
