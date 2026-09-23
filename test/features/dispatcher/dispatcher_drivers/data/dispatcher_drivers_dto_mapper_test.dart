import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/mapper/dispatcher_drivers_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/models/response/dispatcher_drivers_roster_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/models/response/driver_assignment_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';

void main() {
  group('DispatcherDriversRosterResponseDto and Mapper', () {
    final validByAreaJson = {
      'counts': {'totalCount': 13, 'availableCount': 8, 'busyCount': 5},
      'selectedView': 'ByArea',
      'selectedArea': 'السالمية',
      'selectedAreaKey': 'salmiya',
      'sectionTitle': 'سائقو السالمية (8)',
      'areas': [
        {
          'name': 'السالمية',
          'areaKey': 'salmiya',
          'driverCount': 8,
          'isSelected': true,
        },
        {
          'name': 'حولي',
          'areaKey': 'hawally',
          'driverCount': 5,
          'isSelected': false,
        },
      ],
      'drivers': [
        {
          'driverId': '11111111-1111-1111-1111-111111111111',
          'driverCode': 'ID:D-1025',
          'fullName': 'أحمد إبراهيم',
          'avatarUrl': 'https://example.com/avatar1.jpg',
          'rating': 4.9,
          'status': 'Available',
          'statusText': 'متاح',
          'statusDotColor': '#10B981',
          'isAvailableForSelection': true,
          'activeOrdersCount': 0,
          'activeOrdersText': '0 بوكسات',
          'completedOrdersTodayCount': 14,
          'completedOrdersText': '14 توصيلة اليوم',
          'distanceKm': 2.4,
          'distanceText': '2.4 كم',
          'currentZoneName': 'السالمية',
          'currentZoneKey': 'salmiya',
        },
        {
          'driverId': '22222222-2222-2222-2222-222222222222',
          'driverCode': 'ID:D-1026',
          'fullName': 'محمد السعيد',
          'avatarUrl': null,
          'rating': 4.7,
          'status': 'Busy',
          'statusText': 'مشغول بتسليم',
          'statusDotColor': '#F59E0B',
          'isAvailableForSelection': false,
          'activeOrdersCount': 2,
          'activeOrdersText': '2 بوكسات',
          'completedOrdersTodayCount': 11,
          'completedOrdersText': '11 توصيلة اليوم',
          'distanceKm': 3.1,
          'distanceText': '3.1 كم',
          'currentZoneName': 'السالمية',
          'currentZoneKey': 'salmiya',
        },
        {
          'driverId': '33333333-3333-3333-3333-333333333333',
          'driverCode': 'ID:D-1027',
          'fullName': 'خالد العنزي',
          'avatarUrl': null,
          'rating': 4.5,
          'status': 'OnBreak',
          'statusText': 'استراحة',
          'statusDotColor': '#6B7280',
          'isAvailableForSelection': false,
          'activeOrdersCount': 0,
          'activeOrdersText': '0 بوكسات',
          'completedOrdersTodayCount': 8,
          'completedOrdersText': '8 توصيلات اليوم',
          'distanceKm': 5.0,
          'distanceText': '5.0 كم',
          'currentZoneName': 'السالمية',
          'currentZoneKey': 'salmiya',
        },
      ],
    };

    final validAllJson = {
      'counts': {'totalCount': 13, 'availableCount': 8, 'busyCount': 5},
      'selectedView': 'All',
      'selectedArea': null,
      'selectedAreaKey': null,
      'sectionTitle': 'جميع السائقين (13)',
      'areas': [],
      'drivers': [],
    };

    test('maps valid ByArea sample correctly', () {
      final dto = DispatcherDriversRosterResponseDto.fromJson(validByAreaJson);
      final entity = dto.toEntity();

      expect(entity.counts.totalCount, 13);
      expect(entity.counts.availableCount, 8);
      expect(entity.counts.busyCount, 5);
      expect(entity.selectedView, DispatcherDriverViewMode.byArea);
      expect(entity.selectedAreaKey, 'salmiya');
      expect(entity.selectedAreaName, 'السالمية');
      expect(entity.sectionTitle, 'سائقو السالمية (8)');
      expect(entity.areas.length, 2);
      expect(entity.areas.first.name, 'السالمية');
      expect(entity.areas.first.isSelected, isTrue);

      expect(entity.drivers.length, 3);
      final firstDriver = entity.drivers.first;
      expect(firstDriver.driverId, '11111111-1111-1111-1111-111111111111');
      expect(firstDriver.driverCode, 'ID:D-1025');
      expect(firstDriver.fullName, 'أحمد إبراهيم');
      expect(firstDriver.rating, 4.9);
      expect(firstDriver.status, DispatcherDriverStatus.available);
      expect(firstDriver.isAvailableForSelection, isTrue);
      expect(firstDriver.distanceKm, 2.4);

      final secondDriver = entity.drivers[1];
      expect(secondDriver.status, DispatcherDriverStatus.busy);
      expect(secondDriver.isAvailableForSelection, isFalse);

      final thirdDriver = entity.drivers[2];
      expect(thirdDriver.status, DispatcherDriverStatus.onBreak);
      expect(thirdDriver.isAvailableForSelection, isFalse);
    });

    test('maps valid All sample correctly', () {
      final dto = DispatcherDriversRosterResponseDto.fromJson(validAllJson);
      final entity = dto.toEntity();

      expect(entity.counts.totalCount, 13);
      expect(entity.selectedView, DispatcherDriverViewMode.allDrivers);
      expect(entity.selectedAreaKey, isNull);
      expect(entity.areas, isEmpty);
      expect(entity.drivers, isEmpty);
    });

    test('handles completely null fields safely and defensively', () {
      final dto = DispatcherDriversRosterResponseDto.fromJson(const {});
      final entity = dto.toEntity();

      expect(entity.counts.totalCount, 0);
      expect(entity.counts.availableCount, 0);
      expect(entity.counts.busyCount, 0);
      expect(entity.selectedView, DispatcherDriverViewMode.byArea);
      expect(entity.selectedAreaKey, isNull);
      expect(entity.selectedAreaName, '');
      expect(entity.sectionTitle, '');
      expect(entity.areas, isEmpty);
      expect(entity.drivers, isEmpty);
    });

    test(
      'driver item with unknown status and null flags defaults defensively',
      () {
        final driverDto = DispatcherDriverItemDto.fromJson({
          'driverId': 'test-id',
          'status': 'StrangeStatus',
          'isAvailableForSelection': null,
        });
        final entity = driverDto.toEntity();

        expect(entity.driverId, 'test-id');
        expect(entity.status, DispatcherDriverStatus.unknown);
        expect(entity.isAvailableForSelection, isFalse);
        expect(entity.activeOrdersCount, 0);
        expect(entity.completedOrdersTodayCount, 0);
        expect(entity.distanceKm, 0.0);
        expect(entity.rating, 0.0);
      },
    );
  });

  group('AssignDriverRequestDto and Mapper', () {
    test('serializes to expected API json body', () {
      const entity = AssignDriverRequestEntity(
        boxId: 'a1111111-1111-1111-1111-111111111111',
        driverId: '11111111-1111-1111-1111-111111111111',
        notes: 'إسناد مباشر من قائمة السائقين',
      );

      final dto = entity.toDto();
      final json = dto.toJson();

      expect(json['driverId'], '11111111-1111-1111-1111-111111111111');
      expect(json['notes'], 'إسناد مباشر من قائمة السائقين');
      // boxId belongs in URL path, not body
      expect(json.containsKey('boxId'), isFalse);
    });
  });

  group('DriverAssignmentResponseDto and Mapper', () {
    test('maps valid assignment response', () {
      final json = {
        'success': true,
        'message': 'تم إسناد السائق بنجاح',
        'assignedAt': '2026-09-23T10:00:00Z',
        'boxId': 'box-1',
        'driverId': 'drv-1',
      };
      final dto = DriverAssignmentResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.success, isTrue);
      expect(entity.message, 'تم إسناد السائق بنجاح');
      expect(entity.assignedAt, DateTime.parse('2026-09-23T10:00:00Z'));
      expect(entity.boxId, 'box-1');
      expect(entity.driverId, 'drv-1');
    });

    test('handles invalid assignedAt timestamp safely', () {
      final json = {
        'success': true,
        'message': 'OK',
        'assignedAt': 'not-a-date',
      };
      final dto = DriverAssignmentResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.assignedAt, isNull);
    });
  });
}
