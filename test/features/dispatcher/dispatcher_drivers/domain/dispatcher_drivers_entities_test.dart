import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_area_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_roster_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';

void main() {
  group('DispatcherDriverViewMode', () {
    test('apiValue maps correctly', () {
      expect(DispatcherDriverViewMode.byArea.apiValue, 'ByArea');
      expect(DispatcherDriverViewMode.allDrivers.apiValue, 'All');
    });

    test('fromApi handles values safely', () {
      expect(
        DispatcherDriverViewModeX.fromApi('ByArea'),
        DispatcherDriverViewMode.byArea,
      );
      expect(
        DispatcherDriverViewModeX.fromApi('All'),
        DispatcherDriverViewMode.allDrivers,
      );
      expect(
        DispatcherDriverViewModeX.fromApi('Unknown'),
        DispatcherDriverViewMode.byArea,
      );
    });
  });

  group('DispatcherDriverStatus', () {
    test('fromApi maps known and unknown values', () {
      expect(
        DispatcherDriverStatusX.fromApi('Available'),
        DispatcherDriverStatus.available,
      );
      expect(
        DispatcherDriverStatusX.fromApi('Busy'),
        DispatcherDriverStatus.busy,
      );
      expect(
        DispatcherDriverStatusX.fromApi('OnTheWay'),
        DispatcherDriverStatus.busy,
      );
      expect(
        DispatcherDriverStatusX.fromApi('OnBreak'),
        DispatcherDriverStatus.onBreak,
      );
      expect(
        DispatcherDriverStatusX.fromApi('UnknownState'),
        DispatcherDriverStatus.unknown,
      );
      expect(
        DispatcherDriverStatusX.fromApi(null),
        DispatcherDriverStatus.unknown,
      );
    });
  });

  group('DispatcherDriversRouteArgs', () {
    test('browse mode is valid and has null boxId', () {
      const args = DispatcherDriversRouteArgs.browse();
      expect(args.mode, DispatcherDriversMode.browse);
      expect(args.boxId, isNull);
      expect(args.isValid, isTrue);
    });

    test('assignment mode validates boxId', () {
      const emptyArgs = DispatcherDriversRouteArgs.assignment(boxId: '');
      expect(emptyArgs.isValid, isFalse);

      const whitespaceArgs = DispatcherDriversRouteArgs.assignment(
        boxId: '   ',
      );
      expect(whitespaceArgs.isValid, isFalse);

      const validArgs = DispatcherDriversRouteArgs.assignment(
        boxId: 'a1111111-1111-1111-1111-111111111111',
      );
      expect(validArgs.isValid, isTrue);
      expect(validArgs.mode, DispatcherDriversMode.assignment);
      expect(validArgs.boxId, 'a1111111-1111-1111-1111-111111111111');
    });
  });

  group('DispatcherDriversQueryEntity', () {
    test('initializes with default view', () {
      const query = DispatcherDriversQueryEntity();
      expect(query.view, DispatcherDriverViewMode.byArea);
      expect(query.areaKey, isNull);
      expect(query.areaName, isNull);
      expect(query.boxId, isNull);
    });
  });

  group('DispatcherDriverEntity & RosterEntity', () {
    test('holds distinct driverId and driverCode', () {
      const driver = DispatcherDriverEntity(
        driverId: '11111111-1111-1111-1111-111111111111',
        driverCode: 'ID:D-1025',
        fullName: 'أحمد إبراهيم',
        avatarUrl: 'https://example.com/avatar.jpg',
        rating: 4.9,
        status: DispatcherDriverStatus.available,
        statusText: 'متاح',
        statusDotColor: '#10B981',
        isAvailableForSelection: true,
        activeOrdersCount: 0,
        activeOrdersText: '0 بوكسات',
        completedOrdersTodayCount: 14,
        completedOrdersText: '14 توصيلة اليوم',
        distanceKm: 2.4,
        distanceText: '2.4 كم',
        currentZoneName: 'السالمية',
        currentZoneKey: 'salmiya',
      );

      expect(driver.driverId, '11111111-1111-1111-1111-111111111111');
      expect(driver.driverCode, 'ID:D-1025');
      expect(driver.fullName, 'أحمد إبراهيم');
      expect(driver.isAvailableForSelection, isTrue);
    });

    test('counts provide totalCount and count aliases', () {
      const counts = DispatcherDriversKpiEntity(
        totalCount: 13,
        availableCount: 8,
        busyCount: 5,
      );
      expect(counts.totalCount, 13);
      expect(counts.availableCount, 8);
      expect(counts.busyCount, 5);
      expect(counts.totalDrivers, 13);
      expect(counts.availableDrivers, 8);
      expect(counts.busyNow, 5);
    });

    test('DispatcherDriversRosterEntity contains areas and drivers', () {
      const roster = DispatcherDriversRosterEntity(
        counts: DispatcherDriversKpiEntity(
          totalCount: 13,
          availableCount: 8,
          busyCount: 5,
        ),
        selectedView: DispatcherDriverViewMode.byArea,
        selectedAreaKey: 'salmiya',
        selectedAreaName: 'السالمية',
        sectionTitle: 'سائقو السالمية (8)',
        areas: [
          DispatcherDriverAreaEntity(
            name: 'السالمية',
            areaKey: 'salmiya',
            driverCount: 8,
            isSelected: true,
          ),
        ],
        drivers: [],
      );

      expect(roster.selectedAreaKey, 'salmiya');
      expect(roster.areas.first.driverCount, 8);
    });
  });

  group('AssignDriverRequestEntity and DriverAssignmentResultEntity', () {
    test('constructs assignment request and result', () {
      const req = AssignDriverRequestEntity(
        boxId: 'box-123',
        driverId: 'drv-456',
        notes: 'ملاحظة',
      );
      expect(req.boxId, 'box-123');
      expect(req.driverId, 'drv-456');

      final result = DriverAssignmentResultEntity(
        success: true,
        message: 'تم الإسناد بنجاح',
        assignedAt: DateTime.parse('2026-09-23T10:00:00Z'),
        boxId: 'box-123',
        driverId: 'drv-456',
      );
      expect(result.success, isTrue);
      expect(result.message, 'تم الإسناد بنجاح');
    });
  });

  group('AssignBoxOrderEntity', () {
    test('requires stable boxId GUID', () {
      const order = AssignBoxOrderEntity(
        boxId: 'a1111111-1111-1111-1111-111111111111',
        boxCode: '#BX-1256',
        statusText: 'جديد',
        areaText: 'السالمية',
        distanceText: '6.2 كم',
        deliveryTimeWindow: '09:30-10:30',
        priorityText: 'عالية',
        mealsCountText: '8',
        recommendedDriver: AssignBoxCandidateDriverEntity(
          id: 'drv-1',
          name: 'سالم',
          statusText: 'متاح',
          statusType: AssignBoxDriverStatusType.available,
          tagText: 'الأقرب',
          distanceText: '4.8 كم',
          currentLoadText: '4',
        ),
        candidates: [],
      );

      expect(order.boxId, 'a1111111-1111-1111-1111-111111111111');
      expect(order.boxCode, '#BX-1256');
    });
  });
}
