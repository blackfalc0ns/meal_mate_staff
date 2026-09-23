import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/mapper/driver_performance_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_comparison_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/models/response/driver_performance_overview_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_delay_level.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_category.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';

void main() {
  group('DriverPerformance DTO and Mapper Tests', () {
    test(
      'Overview complete json maps correctly to DriverPerformanceOverviewEntity',
      () {
        final json = {
          'period': 'Last7Days',
          'periodText': 'Last 7 days',
          'dateRangeText': 'May 1 - May 7',
          'fromDate': '2025-05-01',
          'toDate': '2025-05-07',
          'kpis': {
            'totalBoxes': 128,
            'totalBoxesText': '128',
            'deliveredCount': 112,
            'deliveredCountText': '112',
            'deliveredPercentage': 87.5,
            'deliveredPercentageText': '87.5%',
            'avgDelayMinutes': 14,
            'avgDelayText': '14m',
            'overallRating': 4.6,
            'overallRatingText': '4.6',
            'failedCount': 4,
            'failedCountText': '4',
            'failedPercentage': 3.1,
            'failedPercentageText': '3.1%',
          },
          'distribution': {
            'totalBoxes': 128,
            'segments': [
              {
                'id': 'seg_1',
                'key': 'onTime',
                'name': 'On Time',
                'count': 100,
                'percentage': 78.1,
                'color': '#10B981',
              },
              {
                'id': 'seg_2',
                'key': 'Delayed',
                'name': 'Late',
                'count': 20,
                'percentage': 15.6,
                'color': '#F59E0B',
              },
            ],
          },
          'topDrivers': [
            {
              'rank': 1,
              'driverId': 'dr_1',
              'driverCode': 'DR-1025',
              'name': 'Ahmad',
              'rating': 4.9,
              'avatarUrl': 'https://example.com/avatar.jpg',
            },
          ],
          'driversTable': [
            {
              'driverId': 'dr_1',
              'driverCode': 'DR-1025',
              'fullName': 'Ahmad',
              'avatarUrl': 'https://example.com/avatar.jpg',
              'status': 'available',
              'statusDotColorKey': 'success',
              'deliveredCount': 32,
              'deliveredCountText': '32',
              'deliveredPercentage': 90.0,
              'deliveredPercentageText': '(90%)',
              'avgDelayMinutes': 8,
              'avgDelayText': '8m',
              'delayLevel': 'good',
              'failedDeliveryCount': 0,
              'failedDeliveryCountText': '0',
              'failedDeliveryPercentage': 0.0,
              'failedDeliveryPercentageText': '(0%)',
              'rating': 4.9,
            },
          ],
        };

        final entity = DriverPerformanceOverviewResponseDto.fromJson(
          json,
        ).toEntity();

        expect(entity.period, DriverPerformancePeriod.last7Days);
        expect(entity.periodText, 'Last 7 days');
        expect(entity.fromDate, DateTime.utc(2025, 5, 1));
        expect(entity.toDate, DateTime.utc(2025, 5, 7));
        expect(entity.kpis.totalBoxes, 128);
        expect(entity.kpis.deliveredCount, 112);
        expect(entity.kpis.overallRating, 4.6);
        expect(entity.distribution.totalBoxes, 128);
        expect(
          entity.distribution.segments.first.category,
          DriverPerformanceDistributionCategory.onTime,
        );
        expect(
          entity.distribution.segments[1].category,
          DriverPerformanceDistributionCategory.late,
        );
        expect(entity.topDrivers.length, 1);
        expect(entity.topDrivers.first.name, 'Ahmad');
        expect(
          entity.driversTable.first.delayLevel,
          DriverPerformanceDelayLevel.good,
        );
        expect(
          entity.driversTable.first.status,
          DriverPerformanceDriverStatus.available,
        );
        expect(entity.driversTable.first.deliveredCount, 32);
      },
    );

    test('Overview empty and malformed json handles defensive fallbacks', () {
      final json = <String, dynamic>{
        'fromDate': 'invalid-date',
        'toDate': null,
        'kpis': null,
        'distribution': null,
        'topDrivers': null,
        'driversTable': [
          {
            'status': 'future_unknown_status',
            'delayLevel': 'unrecognized_level',
            'deliveredCount': null,
            'avgDelayMinutes': null,
            'rating': null,
          },
        ],
      };

      final entity = DriverPerformanceOverviewResponseDto.fromJson(
        json,
      ).toEntity();

      expect(entity.period, DriverPerformancePeriod.unknown);
      expect(entity.fromDate, isNull);
      expect(entity.toDate, isNull);
      expect(entity.kpis.totalBoxes, 0);
      expect(entity.kpis.overallRating, 0.0);
      expect(entity.distribution.totalBoxes, 0);
      expect(entity.distribution.segments, isEmpty);
      expect(entity.topDrivers, isEmpty);
      expect(entity.driversTable.length, 1);
      expect(
        entity.driversTable.first.status,
        DriverPerformanceDriverStatus.unknown,
      );
      expect(
        entity.driversTable.first.delayLevel,
        DriverPerformanceDelayLevel.unknown,
      );
      expect(entity.driversTable.first.deliveredCount, 0);
      expect(entity.driversTable.first.avgDelayMinutes, 0);
      expect(entity.driversTable.first.rating, 0.0);
    });

    test(
      'Comparison complete json maps correctly to DriverPerformanceComparisonEntity',
      () {
        final json = {
          'period': 'ThisMonth',
          'periodText': 'This Month',
          'dateRangeText': 'May 1 - May 31',
          'fromDate': '2025-05-01',
          'toDate': '2025-05-31',
          'drivers': [
            {
              'driverId': 'dr_1',
              'driverCode': 'DR-1025',
              'fullName': 'Ahmad',
              'avatarUrl': null,
              'totalAssigned': 50,
              'deliveredCount': 45,
              'deliveredPercentage': 90.0,
              'onTimePercentage': 88.0,
              'avgDelayMinutes': 7,
              'delayLevel': 'good',
              'rating': 4.8,
              'failedCount': 1,
              'failedPercentage': 2.0,
              'totalDistanceKm': 150.5,
            },
          ],
        };

        final entity = DriverPerformanceComparisonResponseDto.fromJson(
          json,
        ).toEntity();

        expect(entity.period, DriverPerformancePeriod.thisMonth);
        expect(entity.drivers.length, 1);
        final driver = entity.drivers.first;
        expect(driver.driverId, 'dr_1');
        expect(driver.totalAssigned, 50);
        expect(driver.onTimePercentage, 88.0);
        expect(driver.delayLevel, DriverPerformanceDelayLevel.good);
        expect(driver.totalDistanceKm, 150.5);
        expect(driver.avatarUrl, isNull);
      },
    );

    test(
      'Overview real live API payload maps correctly without losing fields',
      () {
        final json = {
          "period": "Last7Days",
          "periodText": "آخر 7 أيام",
          "dateRangeText": "16 سبتمبر - 23 سبتمبر 2026",
          "kpis": {
            "totalBoxes": 308,
            "deliveredCount": 88,
            "deliveredPercentage": 28.6,
            "avgDelayMinutes": 0,
            "overallRating": 4.7,
            "failedCount": 88,
            "failedPercentage": 28.6,
          },
          "distribution": {
            "totalCount": 308,
            "segments": [
              {
                "key": "OnTime",
                "title": "تم في الوقت",
                "count": 88,
                "percentage": 28.6,
                "colorHex": "#10B981",
              },
              {
                "key": "Delayed",
                "title": "متأخر",
                "count": 0,
                "percentage": 0,
                "colorHex": "#F59E0B",
              },
              {
                "key": "Failed",
                "title": "فشل التسليم",
                "count": 88,
                "percentage": 28.6,
                "colorHex": "#EF4444",
              },
              {
                "key": "Cancelled",
                "title": "ملغي",
                "count": 0,
                "percentage": 0,
                "colorHex": "#9CA3AF",
              },
            ],
          },
          "topDrivers": [
            {
              "rank": 1,
              "driverId": "97c9a81f-d3f6-4312-86ed-3e8244c81d38",
              "driverCode": "L-10254",
              "fullName": "أحمد السعيد",
              "rating": 4.8,
              "avatarUrl": "https://cdn.mealmate.app/avatars/97c9a81f.jpg",
              "isHighlighted": true,
            },
          ],
          "driversTable": [
            {
              "driverId": "97c9a81f-d3f6-4312-86ed-3e8244c81d38",
              "driverCode": "L-10254",
              "fullName": "أحمد السعيد",
              "avatarUrl": "https://cdn.mealmate.app/avatars/97c9a81f.jpg",
              "status": "Available",
              "statusDotColor": "Green",
              "deliveredCount": 22,
              "deliveredRate": 20.0,
              "deliveredRateText": "20٫0%",
              "avgDelayMinutes": 0,
              "avgDelayText": "0 د",
              "avgDelayColor": "Green",
              "failedCount": 44,
              "failedRate": 40.0,
              "failedRateText": "40٫0%",
              "rating": 4.8,
              "avgDelayLevel": "Good",
            },
            {
              "driverId": "a30817de-4920-4028-ba23-76316f41cda3",
              "driverCode": "L-30819",
              "fullName": "محمد العنزي",
              "avatarUrl": "https://cdn.mealmate.app/avatars/a30817de.jpg",
              "status": "Busy",
              "statusDotColor": "Orange",
              "deliveredCount": 22,
              "deliveredRate": 33.3,
              "deliveredRateText": "33٫3%",
              "avgDelayMinutes": 0,
              "avgDelayText": "0 د",
              "avgDelayColor": "Green",
              "failedCount": 0,
              "failedRate": 0,
              "failedRateText": "0%",
              "rating": 4.5,
              "avgDelayLevel": "Good",
            },
          ],
          "fromDate": "2026-09-16",
          "toDate": "2026-09-23",
        };

        final entity = DriverPerformanceOverviewResponseDto.fromJson(
          json,
        ).toEntity();

        expect(entity.period, DriverPerformancePeriod.last7Days);
        expect(entity.periodText, "آخر 7 أيام");
        expect(entity.distribution.totalBoxes, 308);
        expect(entity.distribution.segments.first.name, "تم في الوقت");
        expect(entity.distribution.segments.first.colorHex, "#10B981");

        expect(entity.topDrivers.first.name, "أحمد السعيد");
        expect(entity.topDrivers.first.isHighlighted, isTrue);

        final row1 = entity.driversTable.first;
        expect(row1.fullName, "أحمد السعيد");
        expect(row1.status, DriverPerformanceDriverStatus.available);
        expect(row1.statusDotColorKey, "Green");
        expect(row1.deliveredPercentage, 20.0);
        expect(row1.deliveredPercentageText, "20٫0%");
        expect(row1.failedDeliveryCount, 44);
        expect(row1.failedDeliveryPercentage, 40.0);
        expect(row1.failedDeliveryPercentageText, "40٫0%");
        expect(row1.delayLevel, DriverPerformanceDelayLevel.good);
        expect(row1.avgDelayColor, "Green");

        final row2 = entity.driversTable[1];
        expect(row2.status, DriverPerformanceDriverStatus.busy);
        expect(row2.statusDotColorKey, "Orange");
        expect(row2.deliveredPercentage, 33.3);
      },
    );
  });
}
