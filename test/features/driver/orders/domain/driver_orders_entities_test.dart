import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_filter.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_query_entity.dart';

void main() {
  group('Driver Orders Domain Entities Test', () {
    test('DriverOrdersFilter wireValue correctness', () {
      expect(DriverOrdersFilter.all.wireValue, 'All');
      expect(DriverOrdersFilter.inProgress.wireValue, 'InProgress');
      expect(DriverOrdersFilter.delivered.wireValue, 'Delivered');
      expect(DriverOrdersFilter.failed.wireValue, 'Failed');
    });

    test('DriverOrdersQueryEntity defaults and copyWith', () {
      const defaultQuery = DriverOrdersQueryEntity();
      expect(defaultQuery.search, '');
      expect(defaultQuery.filter, DriverOrdersFilter.all);

      final updated = defaultQuery.copyWith(
        search: 'BX-123',
        filter: DriverOrdersFilter.inProgress,
      );
      expect(updated.search, 'BX-123');
      expect(updated.filter, DriverOrdersFilter.inProgress);
    });

    test('DriverDeliveryStopEntity derived getters', () {
      const stopWithCoords = DriverDeliveryStopEntity(
        tripStopId: 'ts1',
        boxId: 'b1',
        boxCode: 'BX-001',
        sequenceNumber: 1,
        customerName: 'Ali',
        deliveryZone: 'Salmiya',
        formattedAddress: 'Salmiya St 10',
        latitude: 29.33,
        longitude: 48.07,
        mealsCount: 2,
        mealsSummary: '2 Meals',
        deliveryTimeSlot: '10:00',
        status: DriverDeliveryStatus.inProgress,
        statusText: 'In Progress',
        isCurrentStop: true,
        canCompleteDelivery: true,
        canNavigate: true,
        canCallCustomer: true,
      );

      expect(stopWithCoords.hasCoordinates, true);
      expect(stopWithCoords.isProblem, false);
      expect(stopWithCoords.isCompleted, false);
      expect(stopWithCoords.canShowPrimaryActions, true);

      const failedStop = DriverDeliveryStopEntity(
        tripStopId: 'ts2',
        boxId: 'b2',
        boxCode: 'BX-002',
        sequenceNumber: 2,
        customerName: 'Sara',
        deliveryZone: 'Hawally',
        formattedAddress: 'Hawally St 2',
        latitude: null,
        longitude: null,
        mealsCount: 1,
        mealsSummary: '1 Meal',
        deliveryTimeSlot: '10:30',
        status: DriverDeliveryStatus.failed,
        statusText: 'Failed',
        isCurrentStop: false,
        canCompleteDelivery: false,
        canNavigate: false,
        canCallCustomer: false,
      );

      expect(failedStop.hasCoordinates, false);
      expect(failedStop.isProblem, true);
      expect(failedStop.isCompleted, false);
      expect(failedStop.canShowPrimaryActions, false);
    });

    test('DriverDeliveryManifestEntity properties and immutability', () {
      final manifest = DriverDeliveryManifestEntity(
        tripId: 'trip-100',
        tripCode: 'TRP-100',
        tripStatus: 'InProgress',
        tripStatusText: 'On Delivery',
        totalCount: 3,
        inProgressCount: 1,
        deliveredCount: 1,
        failedCount: 1,
        stops: const [],
      );

      expect(manifest.hasActiveTrip, true);
      expect(manifest.isEmpty, true);
      expect(manifest.stops, isA<List>());

      const emptyManifest = DriverDeliveryManifestEntity.empty();

      expect(emptyManifest.hasActiveTrip, false);
    });
  });
}
