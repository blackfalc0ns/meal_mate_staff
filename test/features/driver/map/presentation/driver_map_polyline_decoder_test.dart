import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_polyline_decoder.dart';

void main() {
  const decoder = DriverMapPolylineDecoder();

  group('DriverMapPolylineDecoder', () {
    test('decodes standard Google polyline5 string into correct coordinates', () {
      // Standard test vector from plan:
      // (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
      const encoded = r'_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = decoder.decode(encoded);

      expect(points.length, 3);
      expect(points[0].latitude, closeTo(38.5, 1e-5));
      expect(points[0].longitude, closeTo(-120.2, 1e-5));
      expect(points[1].latitude, closeTo(40.7, 1e-5));
      expect(points[1].longitude, closeTo(-120.95, 1e-5));
      expect(points[2].latitude, closeTo(43.252, 1e-5));
      expect(points[2].longitude, closeTo(-126.453, 1e-5));
    });

    test('returns empty list for null, empty or whitespace input', () {
      expect(decoder.decode(null), isEmpty);
      expect(decoder.decode(''), isEmpty);
      expect(decoder.decode('   '), isEmpty);
    });

    test('returns empty list for non-google_polyline5 encoding', () {
      expect(
        decoder.decode(r'_p~iF~ps|U_ulLnnqC_mqNvxq`@', encoding: 'other_encoding'),
        isEmpty,
      );
    });

    test('returns empty list safely for malformed encoded string without crashing', () {
      expect(decoder.decode('invalid_corrupted_polyline!~'), isEmpty);
    });
  });
}
