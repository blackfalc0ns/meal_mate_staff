import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/home/data/models/response/driver_home_response_dto.dart';

void main() {
  group('DriverHomeResponseDto', () {
    test('decodes full inactive response correctly', () {
      final json = <String, dynamic>{
        'driverId': 'drv-123',
        'driverName': 'أحمد السائق',
        'driverCode': 'DRV101',
        'profileImageUrl': 'https://example.com/avatar.png',
        'shiftStatus': 'Inactive',
        'isAvailable': false,
        'currentStatusText': 'غير متصل',
        'nextLocationText': null,
        'targetProgress': null,
        'currentDeliveryTask': null,
        'todaySummary': null,
        'dailyPerformance': null,
        'activeSession': null,
        'unreadNotificationsCount': 0,
      };

      final dto = DriverHomeResponseDto.fromJson(json);

      expect(dto.driverId, 'drv-123');
      expect(dto.driverName, 'أحمد السائق');
      expect(dto.driverCode, 'DRV101');
      expect(dto.profileImageUrl, 'https://example.com/avatar.png');
      expect(dto.shiftStatus, 'Inactive');
      expect(dto.isAvailable, false);
      expect(dto.currentStatusText, 'غير متصل');
      expect(dto.nextLocationText, isNull);
      expect(dto.targetProgress, isNull);
      expect(dto.currentDeliveryTask, isNull);
      expect(dto.todaySummary, isNull);
      expect(dto.dailyPerformance, isNull);
      expect(dto.activeSession, isNull);
      expect(dto.unreadNotificationsCount, 0);
    });

    test('decodes active available response with nested metrics', () {
      final json = <String, dynamic>{
        'driverId': 'drv-123',
        'driverName': 'أحمد السائق',
        'driverCode': 'DRV101',
        'profileImageUrl': null,
        'shiftStatus': 'Active',
        'isAvailable': true,
        'currentStatusText': 'متاح وجاهز لاستلام طلب',
        'nextLocationText': 'اليرموك - قطعة 3',
        'targetProgress': {
          'targetPercentage': 75.0,
          'targetText': '75%',
          'completedBoxes': 6,
          'totalBoxes': 8,
        },
        'currentDeliveryTask': null,
        'todaySummary': {
          'completedTripsCount': 2,
          'completedBoxesCount': 6,
          'totalDeliveredBoxesCount': 6,
          'failedDeliveriesCount': 0,
          'collectedCashAmount': 45.5,
          'totalEarnings': 120.0,
          'currency': 'KWD',
        },
        'dailyPerformance': {
          'deliveredOrdersCount': 6,
          'onTimeDeliveryRate': 98.5,
          'customerRating': 4.9,
          'acceptanceRate': 95.0,
        },
        'activeSession': {
          'shiftId': 'sh-001',
          'startedAtUtc': '2026-10-05T08:00:00Z',
          'durationMinutes': 120,
          'status': 'Active',
        },
        'unreadNotificationsCount': 3,
      };

      final dto = DriverHomeResponseDto.fromJson(json);

      expect(dto.shiftStatus, 'Active');
      expect(dto.isAvailable, true);
      expect(dto.targetProgress?.completedBoxes, 6);
      expect(dto.targetProgress?.targetPercentage, 75.0);
      expect(dto.todaySummary?.collectedCashAmount, 45.5);
      expect(dto.todaySummary?.currency, 'KWD');
      expect(dto.dailyPerformance?.customerRating, 4.9);
      expect(dto.activeSession?.durationMinutes, 120);
      expect(dto.unreadNotificationsCount, 3);
      expect(dto.currentDeliveryTask, isNull);
    });

    test('decodes active busy response with full delivery task fields', () {
      final json = <String, dynamic>{
        'driverId': 'drv-123',
        'driverName': 'أحمد السائق',
        'driverCode': 'DRV101',
        'shiftStatus': 'Active',
        'isAvailable': false,
        'currentStatusText': 'في الطريق إلى العميل',
        'currentDeliveryTask': {
          'boxId': 'box-789',
          'boxCode': 'BOX-01',
          'customerName': 'فاطمة محمد',
          'customerPhone': '+96598765432',
          'deliveryAddress': 'حولي - شارع تونس - بناية 12',
          'destinationLatitude': 29.3375,
          'destinationLongitude': 48.0281,
          'mealsCount': 3,
          'mealsSummary': '3 وجبات دايت',
          'deliveryTimeSlot': '12:00 - 13:00',
          'status': 'InTransit',
          'deliveryNotes': 'يرجى الاتصال عند الوصول',
        },
      };

      final dto = DriverHomeResponseDto.fromJson(json);

      expect(dto.shiftStatus, 'Active');
      expect(dto.isAvailable, false);
      final task = dto.currentDeliveryTask;
      expect(task, isNotNull);
      expect(task?.boxId, 'box-789');
      expect(task?.boxCode, 'BOX-01');
      expect(task?.customerName, 'فاطمة محمد');
      expect(task?.customerPhone, '+96598765432');
      expect(task?.deliveryAddress, 'حولي - شارع تونس - بناية 12');
      expect(task?.destinationLatitude, 29.3375);
      expect(task?.destinationLongitude, 48.0281);
      expect(task?.mealsCount, 3);
      expect(task?.mealsSummary, '3 وجبات دايت');
      expect(task?.deliveryTimeSlot, '12:00 - 13:00');
      expect(task?.status, 'InTransit');
      expect(task?.deliveryNotes, 'يرجى الاتصال عند الوصول');
    });

    test(
      'handles empty json and omitted fields defensively without crashing',
      () {
        final dto = DriverHomeResponseDto.fromJson(const {});

        expect(dto.driverId, isNull);
        expect(dto.driverName, isNull);
        expect(dto.shiftStatus, isNull);
        expect(dto.isAvailable, isNull);
        expect(dto.targetProgress, isNull);
        expect(dto.currentDeliveryTask, isNull);
        expect(dto.todaySummary, isNull);
        expect(dto.dailyPerformance, isNull);
        expect(dto.activeSession, isNull);
        expect(dto.unreadNotificationsCount, isNull);
      },
    );
  });
}
