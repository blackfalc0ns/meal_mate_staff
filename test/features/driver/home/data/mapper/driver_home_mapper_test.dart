import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/home/data/mapper/driver_home_mapper.dart';
import 'package:meal_mate_delivery/features/driver/home/data/models/response/driver_home_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';

void main() {
  group('DriverHomeMapper', () {
    test('normalizes shiftStatus case-insensitively', () {
      expect(
        const DriverHomeResponseDto(
          shiftStatus: 'Active',
        ).toEntity().shiftStatus,
        DriverShiftStatus.active,
      );
      expect(
        const DriverHomeResponseDto(
          shiftStatus: 'active',
        ).toEntity().shiftStatus,
        DriverShiftStatus.active,
      );
      expect(
        const DriverHomeResponseDto(
          shiftStatus: 'ACTIVE',
        ).toEntity().shiftStatus,
        DriverShiftStatus.active,
      );
      expect(
        const DriverHomeResponseDto(
          shiftStatus: 'Inactive',
        ).toEntity().shiftStatus,
        DriverShiftStatus.inactive,
      );
      expect(
        const DriverHomeResponseDto(
          shiftStatus: 'Offline',
        ).toEntity().shiftStatus,
        DriverShiftStatus.inactive,
      );
      expect(
        const DriverHomeResponseDto(shiftStatus: null).toEntity().shiftStatus,
        DriverShiftStatus.inactive,
      );
      expect(
        const DriverHomeResponseDto(
          shiftStatus: 'UnknownState',
        ).toEntity().shiftStatus,
        DriverShiftStatus.inactive,
      );
    });

    test(
      'preserves nullability of operational sections without fabricating empty objects',
      () {
        const dto = DriverHomeResponseDto(
          driverId: 'drv-1',
          driverName: 'سائق',
          driverCode: 'D01',
          shiftStatus: 'Inactive',
          isAvailable: false,
        );

        final entity = dto.toEntity();

        expect(entity.targetProgress, isNull);
        expect(entity.currentDeliveryTask, isNull);
        expect(entity.todaySummary, isNull);
        expect(entity.dailyPerformance, isNull);
        expect(entity.activeSession, isNull);
        expect(entity.nextLocationText, isNull);
        expect(entity.unreadNotificationsCount, 0);
      },
    );

    test('maps all nested operational entities accurately when present', () {
      const dto = DriverHomeResponseDto(
        driverId: 'drv-1',
        driverName: 'أحمد',
        driverCode: 'D10',
        profileImageUrl: 'https://img.com/avatar.jpg',
        shiftStatus: 'Active',
        isAvailable: true,
        currentStatusText: 'متاح',
        nextLocationText: 'الروضة',
        targetProgress: DriverHomeTargetProgressResponseDto(
          targetPercentage: 80.0,
          targetText: '80%',
          completedBoxes: 8,
          totalBoxes: 10,
        ),
        currentDeliveryTask: DriverHomeCurrentDeliveryTaskResponseDto(
          boxId: 'box-101',
          boxCode: 'BX-101',
          customerName: 'سارة',
          customerPhone: '99887766',
          deliveryAddress: 'السرة قطعة 1',
          destinationLatitude: 29.3,
          destinationLongitude: 48.0,
          mealsCount: 2,
          mealsSummary: '2 وجبات',
          deliveryTimeSlot: '13:00 - 14:00',
          status: 'InTransit',
          deliveryNotes: 'يرجى وضعها عند الباب',
        ),
        todaySummary: DriverHomeTodaySummaryResponseDto(
          completedTripsCount: 3,
          completedBoxesCount: 8,
          totalDeliveredBoxesCount: 8,
          failedDeliveriesCount: 0,
          collectedCashAmount: 50.0,
          totalEarnings: 150.0,
          currency: 'KWD',
        ),
        dailyPerformance: DriverHomeDailyPerformanceResponseDto(
          deliveredOrdersCount: 8,
          onTimeDeliveryRate: 99.0,
          customerRating: 4.95,
          acceptanceRate: 100.0,
        ),
        activeSession: DriverHomeActiveSessionResponseDto(
          shiftId: 's-1',
          startedAtUtc: '2026-10-05T08:00:00Z',
          durationMinutes: 90,
          status: 'Active',
        ),
        unreadNotificationsCount: 5,
      );

      final entity = dto.toEntity();

      expect(entity.driverId, 'drv-1');
      expect(entity.driverName, 'أحمد');
      expect(entity.driverCode, 'D10');
      expect(entity.profileImageUrl, 'https://img.com/avatar.jpg');
      expect(entity.shiftStatus, DriverShiftStatus.active);
      expect(entity.isAvailable, true);
      expect(entity.currentStatusText, 'متاح');
      expect(entity.nextLocationText, 'الروضة');

      expect(entity.targetProgress?.targetPercentage, 80.0);
      expect(entity.targetProgress?.completedBoxes, 8);
      expect(entity.targetProgress?.totalBoxes, 10);

      expect(entity.currentDeliveryTask?.boxId, 'box-101');
      expect(entity.currentDeliveryTask?.boxCode, 'BX-101');
      expect(entity.currentDeliveryTask?.customerName, 'سارة');
      expect(entity.currentDeliveryTask?.customerPhone, '99887766');
      expect(entity.currentDeliveryTask?.destinationLatitude, 29.3);
      expect(entity.currentDeliveryTask?.mealsCount, 2);

      expect(entity.todaySummary?.collectedCashAmount, 50.0);
      expect(entity.todaySummary?.currency, 'KWD');

      expect(entity.dailyPerformance?.customerRating, 4.95);
      expect(entity.activeSession?.durationMinutes, 90);
      expect(entity.unreadNotificationsCount, 5);
    });

    test('falls back safely when identity fields are null or empty', () {
      const dto = DriverHomeResponseDto(
        driverId: null,
        driverName: null,
        driverCode: null,
        profileImageUrl: null,
        shiftStatus: null,
        isAvailable: null,
        currentStatusText: null,
      );

      final entity = dto.toEntity();

      expect(entity.driverId, '');
      expect(entity.driverName, '');
      expect(entity.driverCode, '');
      expect(entity.profileImageUrl, isNull);
      expect(entity.shiftStatus, DriverShiftStatus.inactive);
      expect(entity.isAvailable, false);
      expect(entity.currentStatusText, '');
    });
  });
}
