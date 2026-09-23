import 'driver_performance_distribution_entity.dart';
import 'driver_performance_kpis_entity.dart';
import 'driver_performance_period.dart';
import 'driver_performance_record_entity.dart';
import 'driver_podium_entry_entity.dart';

class DriverPerformanceOverviewEntity {
  const DriverPerformanceOverviewEntity({
    required this.period,
    required this.periodText,
    required this.dateRangeText,
    this.fromDate,
    this.toDate,
    required this.kpis,
    required this.distribution,
    required this.topDrivers,
    required this.driversTable,
  });

  final DriverPerformancePeriod period;
  final String periodText;
  final String dateRangeText;
  final DateTime? fromDate;
  final DateTime? toDate;
  final DriverPerformanceKpisEntity kpis;
  final DriverPerformanceDistributionEntity distribution;
  final List<DriverPodiumEntryEntity> topDrivers;
  final List<DriverPerformanceRecordEntity> driversTable;
}
