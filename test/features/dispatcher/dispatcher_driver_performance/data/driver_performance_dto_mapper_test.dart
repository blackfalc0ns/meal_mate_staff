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
      'Comparison empty json handles null lists and null optional metrics',
      () {
        final json = <String, dynamic>{'drivers': null};

        final entity = DriverPerformanceComparisonResponseDto.fromJson(
          json,
        ).toEntity();
        expect(entity.drivers, isEmpty);
        expect(entity.period, DriverPerformancePeriod.unknown);
      },
    );
  });
}
