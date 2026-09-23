import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/delivery_trip_status.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';

void main() {
  group('Active Delivery Domain Entities & Fake Data Test', () {
    test('default trip entity has valid coordinates and required details', () {
      const trip = DriverActiveDeliveryFakeData.defaultTrip;

      expect(trip.tripId, isNotEmpty);
      expect(trip.order.customerName, equals('عبدالله العتيبي'));
      expect(trip.order.boxCode, equals('#BX-1256'));
      expect(trip.status, equals(DeliveryTripStatus.readyToStart));
      expect(trip.driverLocation.isValid, isTrue);
      expect(trip.customerLocation.isValid, isTrue);
      expect(trip.restaurantLocation.isValid, isTrue);
      expect(trip.routePoints, isNotEmpty);
      expect(trip.estimatedMinutes, greaterThan(0));
      expect(trip.distanceKm, greaterThan(0));
    });

    test('failure reasons list is populated', () {
      const reasons = DriverActiveDeliveryFakeData.failureReasons;
      expect(reasons.length, greaterThanOrEqualTo(5));
      expect(reasons.any((r) => r.id == 'no_answer'), isTrue);
    });

    test('copyWith on trip updates status and fields cleanly', () {
      const trip = DriverActiveDeliveryFakeData.defaultTrip;
      final updated = trip.copyWith(status: DeliveryTripStatus.enRoute);

      expect(updated.status, equals(DeliveryTripStatus.enRoute));
      expect(updated.tripId, equals(trip.tripId));
      expect(updated.order.customerName, equals(trip.order.customerName));
    });
  });
}
