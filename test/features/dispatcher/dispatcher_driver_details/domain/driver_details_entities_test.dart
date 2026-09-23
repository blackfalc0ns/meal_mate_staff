import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_driver_details_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_map_route_arguments.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_active_box_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_current_location_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_daily_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_location_point_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_profile_entity.dart';

void main() {
  group('DispatcherDriverDetailsRouteArgs', () {
    test('validates GUID driverId correctly', () {
      expect(
        const DispatcherDriverDetailsRouteArgs(driverId: '').isValid,
        isFalse,
      );
      expect(
        const DispatcherDriverDetailsRouteArgs(driverId: 'invalid-guid').isValid,
        isFalse,
      );
      expect(
        const DispatcherDriverDetailsRouteArgs(
          driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da9',
        ).isValid,
        isTrue,
      );
      expect(
        const DispatcherDriverDetailsRouteArgs(
          driverId: '  4a6f235e-c04d-45db-9c3f-c39775c96da9  ',
        ).isValid,
        isTrue,
      );
    });

    test('supports equality and value comparisons', () {
      const args1 = DispatcherDriverDetailsRouteArgs(
        driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da9',
      );
      const args2 = DispatcherDriverDetailsRouteArgs(
        driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da9',
      );
      expect(args1, equals(args2));
      expect(args1.hashCode, equals(args2.hashCode));
    });
  });

  group('DispatcherMapRouteArgs', () {
    test('supports focusDriverId', () {
      const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';
      const args = DispatcherMapRouteArgs(focusDriverId: driverId);
      expect(args.focusDriverId, driverId);
      expect(args.areaKey, isNull);
      expect(args.areaName, isNull);
    });
  });

  group('DriverDetailsStatusX', () {
    test('maps API strings correctly', () {
      expect(
        DriverDetailsStatusX.fromApi('Available'),
        DriverDetailsStatus.available,
      );
      expect(
        DriverDetailsStatusX.fromApi('available'),
        DriverDetailsStatus.available,
      );
      expect(DriverDetailsStatusX.fromApi('Busy'), DriverDetailsStatus.busy);
      expect(
        DriverDetailsStatusX.fromApi('Delivering'),
        DriverDetailsStatus.delivering,
      );
      expect(
        DriverDetailsStatusX.fromApi('OnDelivery'),
        DriverDetailsStatus.onDelivery,
      );
      expect(
        DriverDetailsStatusX.fromApi('Offline'),
        DriverDetailsStatus.offline,
      );
      expect(
        DriverDetailsStatusX.fromApi('InBreak'),
        DriverDetailsStatus.inBreak,
      );
      expect(DriverDetailsStatusX.fromApi('Break'), DriverDetailsStatus.inBreak);
      expect(
        DriverDetailsStatusX.fromApi('new-value'),
        DriverDetailsStatus.unknown,
      );
      expect(DriverDetailsStatusX.fromApi(null), DriverDetailsStatus.unknown);
    });
  });

  group('DriverDetailsEntity & Aggregate entities', () {
    test('instantiates complete profile and kpis with nullable fields', () {
      const profile = DriverProfileEntity(
        driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da9',
        driverCode: 'DR-1025',
        fullName: 'أحمد السعيد',
        phoneNumber: null,
        avatarUrl: null,
        status: DriverDetailsStatus.available,
        statusText: 'متاح',
        statusDotColor: '#10B981',
        lastUpdatedText: 'الآن',
      );

      const kpis = DriverKpisEntity(
        performanceRating: 4.8,
        avgDelayMinutes: 12,
        deliveredTodayCount: 28,
        activeBoxesCount: 2,
      );

      const dailySummary = DriverDailySummaryEntity(
        approxKm: 120,
        avgDelayMinutes: 12,
        failedDeliveryCount: 1,
        deliveredCount: 28,
      );

      const details = DriverDetailsEntity(
        driver: profile,
        kpis: kpis,
        dailySummary: dailySummary,
      );

      expect(details.driver.driverCode, 'DR-1025');
      expect(details.driver.phoneNumber, isNull);
      expect(details.kpis.activeBoxesCount, 2);
      expect(details.dailySummary.approxKm, 120);
    });

    test('separates raw boxId GUID from display boxCode', () {
      const box = DriverActiveBoxEntity(
        boxId: '3c19356d-f432-47d5-89f5-7e82845c8531',
        boxCode: 'BX-10256',
        customerName: 'محمد الفضلي',
        deliveryAddress: 'السليمانية، الرياض',
        status: 'OnDelivery',
        statusText: 'خارج للتوصيل',
        statusColor: '#6366F1',
        scheduledTimeText: '12:30 م',
        isDelivering: true,
      );

      expect(box.boxId, '3c19356d-f432-47d5-89f5-7e82845c8531');
      expect(box.boxCode, 'BX-10256');
    });

    test('DriverCurrentLocationEntity handles offline state and route points', () {
      const offline = DriverCurrentLocationEntity(
        latitude: null,
        longitude: null,
        statusBadgeText: 'غير متصل',
        timeAgoText: 'منذ 15 دقيقة',
        streetName: 'شارع الملك فهد',
        areaName: 'حي العليا، الرياض',
      );
      expect(offline.isOffline, isTrue);

      const online = DriverCurrentLocationEntity(
        latitude: 29.3375,
        longitude: 47.9784,
        heading: 180.0,
        speed: 45.0,
        destinationLatitude: 29.3400,
        destinationLongitude: 47.9800,
        statusBadgeText: 'مباشر',
        timeAgoText: 'الآن',
        streetName: 'شارع جمال عبد الناصر',
        areaName: 'الشويخ',
        routePoints: [
          DriverLocationPointEntity(latitude: 29.3375, longitude: 47.9784),
          DriverLocationPointEntity(latitude: 29.3400, longitude: 47.9800),
        ],
      );
      expect(online.isOffline, isFalse);
      expect(online.routePoints, hasLength(2));
      expect(online.routePoints.first.latitude, 29.3375);
    });
  });
}
