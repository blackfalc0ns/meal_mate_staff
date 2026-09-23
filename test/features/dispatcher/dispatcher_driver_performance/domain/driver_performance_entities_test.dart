import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_comparison_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_delay_level.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_category.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_distribution_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_record_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_sort_field.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_podium_entry_entity.dart';

void main() {
  group('DriverPerformance Domain Entities Tests', () {
    test('DriverPerformancePeriod matches exact API values and handles unknown', () {
      expect(DriverPerformancePeriod.today.apiValue, 'Today');
      expect(DriverPerformancePeriod.yesterday.apiValue, 'Yesterday');
      expect(DriverPerformancePeriod.last7Days.apiValue, 'Last7Days');
      expect(DriverPerformancePeriod.last30Days.apiValue, 'Last30Days');
      expect(DriverPerformancePeriod.thisMonth.apiValue, 'ThisMonth');
      expect(DriverPerformancePeriod.custom.apiValue, 'Custom');

      expect(DriverPerformancePeriod.fromApi('Last7Days'), DriverPerformancePeriod.last7Days);
      expect(DriverPerformancePeriod.fromApi('ThisMonth'), DriverPerformancePeriod.thisMonth);
      expect(DriverPerformancePeriod.fromApi('future_period'), DriverPerformancePeriod.unknown);
      expect(DriverPerformancePeriod.fromApi(null), DriverPerformancePeriod.unknown);
    });

    test('DriverPerformanceDelayLevel maps values and handles unknown', () {
      expect(DriverPerformanceDelayLevelX.fromApi('good'), DriverPerformanceDelayLevel.good);
      expect(DriverPerformanceDelayLevelX.fromApi('warning'), DriverPerformanceDelayLevel.warning);
      expect(DriverPerformanceDelayLevelX.fromApi('critical'), DriverPerformanceDelayLevel.critical);
      expect(DriverPerformanceDelayLevelX.fromApi('future'), DriverPerformanceDelayLevel.unknown);
      expect(DriverPerformanceDelayLevelX.fromApi(null), DriverPerformanceDelayLevel.unknown);
    });

    test('DriverPerformanceDriverStatus maps values and handles unknown', () {
      expect(DriverPerformanceDriverStatus.fromApi('available'), DriverPerformanceDriverStatus.available);
      expect(DriverPerformanceDriverStatus.fromApi('onTheWay'), DriverPerformanceDriverStatus.onTheWay);
      expect(DriverPerformanceDriverStatus.fromApi('onBreak'), DriverPerformanceDriverStatus.onBreak);
      expect(DriverPerformanceDriverStatus.fromApi('unexpected'), DriverPerformanceDriverStatus.unknown);
      expect(DriverPerformanceDriverStatus.fromApi(null), DriverPerformanceDriverStatus.unknown);
    });

    test('DriverPerformanceDistributionCategory maps Delayed to late and handles unknown', () {
      expect(DriverPerformanceDistributionCategory.fromApi('onTime'), DriverPerformanceDistributionCategory.onTime);
      expect(DriverPerformanceDistributionCategory.fromApi('Delayed'), DriverPerformanceDistributionCategory.late);
      expect(DriverPerformanceDistributionCategory.fromApi('late'), DriverPerformanceDistributionCategory.late);
      expect(DriverPerformanceDistributionCategory.fromApi('failed'), DriverPerformanceDistributionCategory.failed);
      expect(DriverPerformanceDistributionCategory.fromApi('cancelled'), DriverPerformanceDistributionCategory.cancelled);
      expect(DriverPerformanceDistributionCategory.fromApi('unexpected'), DriverPerformanceDistributionCategory.unknown);
      expect(DriverPerformanceDistributionCategory.fromApi(null), DriverPerformanceDistributionCategory.unknown);
    });

    test('DriverPerformanceQueryEntity validates custom date range requirement and formatting', () {
      expect(
        const DriverPerformanceQueryEntity(period: DriverPerformancePeriod.custom).isValid,
        isFalse,
      );

      final invalidRange = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.custom,
        fromDate: DateTime(2025, 5, 10),
        toDate: DateTime(2025, 5, 2),
      );
      expect(invalidRange.isValid, isFalse);

      final validCustom = DriverPerformanceQueryEntity(
        period: DriverPerformancePeriod.custom,
        fromDate: DateTime(2025, 5, 1),
        toDate: DateTime(2025, 5, 10),
      );
      expect(validCustom.isValid, isTrue);
      expect(validCustom.fromDateFormatted, '2025-05-01');
      expect(validCustom.toDateFormatted, '2025-05-10');

      const preset = DriverPerformanceQueryEntity(period: DriverPerformancePeriod.last7Days);
      expect(preset.isValid, isTrue);
    });

    test('Local sorting sorts records immutably without modifying original list', () {
      const driverA = DriverPerformanceRecordEntity(
        driverId: 'd1',
        driverCode: 'DR-1',
        fullName: 'Zaid',
        status: DriverPerformanceDriverStatus.available,
        deliveredCount: 20,
        deliveredPercentage: 80.0,
        avgDelayMinutes: 5,
        delayLevel: DriverPerformanceDelayLevel.good,
        failedDeliveryCount: 2,
        failedDeliveryPercentage: 8.0,
        rating: 4.8,
      );

      const driverB = DriverPerformanceRecordEntity(
        driverId: 'd2',
        driverCode: 'DR-2',
        fullName: 'Amr',
        status: DriverPerformanceDriverStatus.onTheWay,
        deliveredCount: 40,
        deliveredPercentage: 90.0,
        avgDelayMinutes: 15,
        delayLevel: DriverPerformanceDelayLevel.warning,
        failedDeliveryCount: 1,
        failedDeliveryPercentage: 2.0,
        rating: 4.2,
      );

      final originalList = [driverA, driverB];

      // Sort by delivered descending
      final sortedByDeliveredDesc = originalList.sortedByField(
        DriverPerformanceSortField.delivered,
        ascending: false,
      );
      expect(sortedByDeliveredDesc.first.driverId, 'd2');
      expect(sortedByDeliveredDesc.last.driverId, 'd1');
      expect(originalList.first.driverId, 'd1'); // Original remains unchanged

      // Sort by rating descending
      final sortedByRatingDesc = originalList.sortedByField(
        DriverPerformanceSortField.rating,
        ascending: false,
      );
      expect(sortedByRatingDesc.first.driverId, 'd1');
      expect(sortedByRatingDesc.last.driverId, 'd2');

      // Sort by driver name ascending
      final sortedByNameAsc = originalList.sortedByField(
        DriverPerformanceSortField.driver,
        ascending: true,
      );
      expect(sortedByNameAsc.first.driverId, 'd2'); // 'Amr' comes before 'Zaid'
    });

    test('Overview and Comparison aggregates instantiate correctly', () {
      const kpis = DriverPerformanceKpisEntity(
        totalBoxes: 128,
        deliveredCount: 112,
        deliveredPercentage: 87.5,
        avgDelayMinutes: 14,
        overallRating: 4.6,
        failedCount: 4,
        failedPercentage: 3.1,
      );

      const dist = DriverPerformanceDistributionEntity(
        totalBoxes: 128,
        segments: [
          DriverPerformanceDistributionItemEntity(
            id: '1',
            category: DriverPerformanceDistributionCategory.onTime,
            count: 100,
            percentage: 80.0,
          ),
        ],
      );

      final overview = DriverPerformanceOverviewEntity(
        period: DriverPerformancePeriod.last7Days,
        periodText: 'Last 7 days',
        dateRangeText: 'May 1 - May 7',
        fromDate: DateTime(2025, 5, 1),
        toDate: DateTime(2025, 5, 7),
        kpis: kpis,
        distribution: dist,
        topDrivers: const [
          DriverPodiumEntryEntity(rank: 1, name: 'Zaid', rating: 4.9),
        ],
        driversTable: const [],
      );

      expect(overview.kpis.totalBoxes, 128);
      expect(overview.topDrivers.length, 1);

      const comparison = DriverPerformanceComparisonEntity(
        period: DriverPerformancePeriod.last7Days,
        periodText: 'Last 7 days',
        dateRangeText: 'May 1 - May 7',
        drivers: [
          DriverComparisonRecordEntity(
            driverId: 'd1',
            driverCode: 'DR-1',
            fullName: 'Zaid',
            totalAssigned: 50,
            deliveredCount: 45,
            deliveredPercentage: 90.0,
            onTimePercentage: 88.0,
            avgDelayMinutes: 8,
            delayLevel: DriverPerformanceDelayLevel.good,
            rating: 4.8,
            failedCount: 1,
            failedPercentage: 2.0,
            totalDistanceKm: 120.5,
          ),
        ],
      );

      expect(comparison.drivers.first.fullName, 'Zaid');
    });
  });
}
