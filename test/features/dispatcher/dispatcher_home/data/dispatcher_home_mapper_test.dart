import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/mapper/dispatcher_home_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/models/response/dispatcher_dashboard_overview_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/models/response/dispatcher_live_driver_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_map_driver_pin_entity.dart';

void main() {
  test(
    'maps the complete dashboard response without losing backend values',
    () {
      final dto = DispatcherDashboardOverviewResponseDto.fromJson(
        _overviewJson,
      );
      final entity = dto.toEntity();

      expect(entity.restaurant.id, 'restaurant-1');
      expect(entity.restaurant.nameAr, 'مطعم MealMate الكويت');
      expect(entity.kpis.totalOrdersToday, 128);
      expect(entity.operationsStatus.completionRate, 87.5);
      expect(entity.topDrivers.single.completedDeliveriesToday, 14);
      expect(entity.regions.single.percentageChange, 14.5);
      expect(entity.activeIssues.items.last.driverId, 'driver-2');
      expect(entity.activeIssues.summaryEn, 'Delivery delay');
    },
  );

  test(
    'maps every documented live driver status and nullable order fields',
    () {
      const statuses = <String, DispatcherHomePinStatus>{
        'EnRouteToCustomer': DispatcherHomePinStatus.enRouteToCustomer,
        'InDelivery': DispatcherHomePinStatus.inDelivery,
        'OnBreak': DispatcherHomePinStatus.onBreak,
        'Available': DispatcherHomePinStatus.available,
        'FutureStatus': DispatcherHomePinStatus.unknown,
      };

      for (final entry in statuses.entries) {
        final entity = DispatcherLiveDriverResponseDto.fromJson({
          ..._liveDriverJson,
          'status': entry.key,
        }).toEntity();
        expect(entity.status, entry.value);
        expect(entity.plateNumber, 'DX-439612');
        expect(entity.latitude, 29.3759);
        expect(entity.activeOrderId, isNull);
      }
    },
  );

  test('defensively maps an empty response', () {
    final entity = DispatcherDashboardOverviewResponseDto.fromJson(
      const {},
    ).toEntity();

    expect(entity.restaurant.id, isEmpty);
    expect(entity.kpis.totalOrdersToday, 0);
    expect(entity.topDrivers, isEmpty);
    expect(entity.regions, isEmpty);
    expect(entity.activeIssues.items, isEmpty);
  });
}

const _overviewJson = <String, dynamic>{
  'restaurant': {
    'id': 'restaurant-1',
    'nameAr': 'مطعم MealMate الكويت',
    'nameEn': 'MealMate Restaurant Kuwait',
    'role': 'Dispatcher',
  },
  'greeting': {'title': 'مرحبًا', 'subtitle': 'كل شيء تحت السيطرة اليوم'},
  'kpis': {
    'totalOrdersToday': 128,
    'inDeliveryCount': 58,
    'pendingAssignmentCount': 23,
    'activeIssuesCount': 2,
  },
  'operationsStatus': {
    'completionRatePercentage': 87.5,
    'deliveredCount': 112,
    'inDeliveryCount': 58,
    'pendingAssignmentCount': 23,
    'cancelledCount': 7,
  },
  'topDrivers': [
    {
      'driverId': 'driver-1',
      'fullName': 'أحمد السعيد',
      'avatarUrl': 'https://example.com/ahmed.jpg',
      'badge': 'أعلى تقييم',
      'rating': 4.9,
      'completedDeliveriesToday': 14,
    },
  ],
  'regionsSummary': [
    {
      'regionId': 'region-1',
      'regionName': 'السالمية',
      'ordersCount': 38,
      'trend': 'up',
      'percentageChange': 14.5,
    },
  ],
  'activeIssues': {
    'count': 2,
    'summaryAr': 'تأخير في التوصيل',
    'summaryEn': 'Delivery delay',
    'issues': [
      {
        'id': 'issue-1',
        'type': 'DeliveryDelay',
        'severity': 'Warning',
        'orderId': 'order-1',
        'driverName': 'سالم العلي',
        'message': 'Delivery is late',
      },
      {
        'id': 'issue-2',
        'type': 'DriverStationaryTooLong',
        'severity': 'Critical',
        'driverId': 'driver-2',
        'driverName': 'خالد الشمري',
        'message': 'Driver is stationary',
      },
    ],
  },
};

const _liveDriverJson = <String, dynamic>{
  'driverId': 'driver-1',
  'fullName': 'أحمد السعيد',
  'phone': '+96551234001',
  'plateNumber': 'DX-439612',
  'avatarUrl': 'https://example.com/ahmed.jpg',
  'status': 'InDelivery',
  'statusLabelAr': 'في التوصيل',
  'statusLabelEn': 'In Delivery',
  'latitude': 29.3759,
  'longitude': 47.9774,
  'heading': 140.5,
  'speedKmh': 42.0,
  'activeOrderId': null,
  'customerAddress': null,
  'updatedAtUtc': '2026-09-21T09:30:00Z',
};
