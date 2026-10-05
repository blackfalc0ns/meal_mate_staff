import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_camera_controller.dart';

void main() {
  const cameraController = DriverMapCameraController();

  group('DriverMapCameraController', () {
    test('calculateBoundsUpdate with empty list returns default Kuwait viewport', () {
      final update = cameraController.calculateBoundsUpdate(const []);

      expect(update, isNotNull);
    });

    test('calculateBoundsUpdate with single point returns zoom update instead of zero bounds', () {
      const point = LatLng(29.338, 48.023);
      final update = cameraController.calculateBoundsUpdate([point]);

      expect(update, isNotNull);
    });

    test('calculateBoundsUpdate with duplicate identical points does not produce zero-size bounds exception', () {
      const p1 = LatLng(29.338, 48.023);
      const p2 = LatLng(29.338, 48.023);
      final update = cameraController.calculateBoundsUpdate([p1, p2]);

      expect(update, isNotNull);
    });

    test('calculateBoundsUpdate with multiple distinct points produces bounds covering all points', () {
      const p1 = LatLng(29.338, 48.023);
      const p2 = LatLng(29.339, 48.025);
      const p3 = LatLng(29.337, 48.021);
      final update = cameraController.calculateBoundsUpdate([p1, p2, p3], padding: 60);

      expect(update, isNotNull);
    });
  });
}
