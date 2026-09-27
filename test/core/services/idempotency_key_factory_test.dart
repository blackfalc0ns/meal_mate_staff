import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/driver_pickup_location_provider.dart';
import 'package:meal_mate_delivery/core/services/idempotency_key_factory.dart';

void main() {
  group('DriverPickupCoordinates', () {
    test('rejects zero coordinates', () {
      expect(
        () => DriverPickupCoordinates(latitude: 0, longitude: 0),
        throwsArgumentError,
      );
    });

    test('rejects out of range latitude', () {
      expect(
        () => DriverPickupCoordinates(latitude: 91, longitude: 45),
        throwsArgumentError,
      );
      expect(
        () => DriverPickupCoordinates(latitude: -91, longitude: 45),
        throwsArgumentError,
      );
    });

    test('rejects out of range longitude', () {
      expect(
        () => DriverPickupCoordinates(latitude: 25, longitude: 181),
        throwsArgumentError,
      );
      expect(
        () => DriverPickupCoordinates(latitude: 25, longitude: -181),
        throwsArgumentError,
      );
    });

    test('rejects non-finite coordinates', () {
      expect(
        () => DriverPickupCoordinates(latitude: double.infinity, longitude: 45),
        throwsArgumentError,
      );
      expect(
        () => DriverPickupCoordinates(latitude: 25, longitude: double.nan),
        throwsArgumentError,
      );
    });

    test('accepts valid non-zero finite coordinates', () {
      final coords = DriverPickupCoordinates(latitude: 29.3375, longitude: 48.0280);
      expect(coords.latitude, 29.3375);
      expect(coords.longitude, 48.0280);
    });
  });

  group('IdempotencyKeyFactory', () {
    test('creates a different idempotency key for each new operation', () {
      final factory = IdempotencyKeyFactory();
      final key1 = factory.create();
      final key2 = factory.create();
      expect(key1, isNot(key2));
    });

    test('creates RFC-4122 v4 formatted UUID strings', () {
      final factory = IdempotencyKeyFactory();
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      for (var i = 0; i < 20; i++) {
        final key = factory.create();
        expect(key.length, 36);
        expect(uuidRegex.hasMatch(key), isTrue);
      }
    });
  });
}
