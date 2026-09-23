import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/repositories/active_delivery_fake_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/delivery_trip_status.dart';

void main() {
  group('ActiveDeliveryFakeRepositoryImpl Test', () {
    late ActiveDeliveryFakeRepositoryImpl repository;

    setUp(() {
      repository = ActiveDeliveryFakeRepositoryImpl(
        locationTickInterval: const Duration(milliseconds: 50),
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('getActiveTrip returns initial default trip', () async {
      final trip = await repository.getActiveTrip();
      expect(trip.status, equals(DeliveryTripStatus.readyToStart));
      expect(trip.order.customerName, equals('عبدالله العتيبي'));
    });

    test('startDeliveryRoute changes status to enRoute', () async {
      await repository.startDeliveryRoute('TRIP-78912');
      final trip = await repository.getActiveTrip();
      expect(trip.status, equals(DeliveryTripStatus.enRoute));
      expect(trip.startedAt, isNotNull);
    });

    test('watchDriverLocation emits locations on subscription', () async {
      final firstLocation = await repository.watchDriverLocation().first;
      expect(firstLocation.isValid, isTrue);
    });

    test(
      'markArrivedAtCustomer updates status and sets driver to customer location',
      () async {
        await repository.markArrivedAtCustomer('TRIP-78912');
        final trip = await repository.getActiveTrip();
        expect(trip.status, equals(DeliveryTripStatus.arrived));
        expect(
          trip.driverLocation.latitude,
          equals(trip.customerLocation.latitude),
        );
        expect(trip.arrivedAt, isNotNull);
      },
    );

    test(
      'reportDeliveryFailed creates returnBox and sets status to failed',
      () async {
        await repository.reportDeliveryFailed(
          'TRIP-78912',
          'no_answer',
          'Customer did not pick up phone',
        );
        final trip = await repository.getActiveTrip();
        expect(trip.status, equals(DeliveryTripStatus.failed));
        expect(trip.failureReason?.id, equals('no_answer'));
        expect(trip.returnBox, isNotNull);
        expect(trip.returnBox?.note, equals('Customer did not pick up phone'));
      },
    );

    test(
      'confirmBoxReturnedToRestaurant updates status to boxReturned',
      () async {
        await repository.confirmBoxReturnedToRestaurant('TRIP-78912');
        final trip = await repository.getActiveTrip();
        expect(trip.status, equals(DeliveryTripStatus.boxReturned));
      },
    );
  });
}
