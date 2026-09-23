import '../entities/driver_performance_delay_level.dart';
import '../entities/driver_performance_distribution_category.dart';
import '../entities/driver_performance_distribution_item_entity.dart';
import '../entities/driver_performance_driver_status.dart';
import '../entities/driver_performance_kpi_entity.dart';
import '../entities/driver_performance_kpi_type.dart';
import '../entities/driver_performance_record_entity.dart';
import '../entities/driver_podium_entry_entity.dart';

class DriverPerformanceFakeData {
  const DriverPerformanceFakeData._();

  static const int totalBoxesCount = 128;

  static const List<DriverPerformanceKpiEntity> kpiItems = [
    DriverPerformanceKpiEntity(
      id: 'kpi_0',
      type: DriverPerformanceKpiType.totalBoxes,
      value: '128',
      subValue: '',
      isHighlighted: true,
    ),
    DriverPerformanceKpiEntity(
      id: 'kpi_1',
      type: DriverPerformanceKpiType.delivered,
      value: '112',
      subValue: '87.5%',
    ),
    DriverPerformanceKpiEntity(
      id: 'kpi_2',
      type: DriverPerformanceKpiType.avgDelay,
      value: '14',
      subValue: '',
    ),
    DriverPerformanceKpiEntity(
      id: 'kpi_3',
      type: DriverPerformanceKpiType.overallRating,
      value: '4.6',
      subValue: '',
    ),
    DriverPerformanceKpiEntity(
      id: 'kpi_4',
      type: DriverPerformanceKpiType.deliveryFailed,
      value: '4',
      subValue: '3.1%',
    ),
  ];

  static const List<DriverPerformanceRecordEntity> drivers = [
    DriverPerformanceRecordEntity(
      driverId: 'dr_1',
      fullName: 'أحمد السعيد',
      driverCode: 'DR-1025',
      deliveredCount: 32,
      deliveredPercentage: 90.0,
      deliveredCountText: '32',
      deliveredPercentageText: '(90%)',
      avgDelayMinutes: 8,
      delayLevel: DriverPerformanceDelayLevel.good,
      failedDeliveryCount: 0,
      failedDeliveryPercentage: 0.0,
      failedDeliveryCountText: '0',
      failedDeliveryPercentageText: '(0%)',
      rating: 4.9,
      status: DriverPerformanceDriverStatus.available,
    ),
    DriverPerformanceRecordEntity(
      driverId: 'dr_2',
      fullName: 'محمد العنزي',
      driverCode: 'DR-1032',
      deliveredCount: 28,
      deliveredPercentage: 85.0,
      deliveredCountText: '28',
      deliveredPercentageText: '(85%)',
      avgDelayMinutes: 12,
      delayLevel: DriverPerformanceDelayLevel.warning,
      failedDeliveryCount: 1,
      failedDeliveryPercentage: 3.0,
      failedDeliveryCountText: '1',
      failedDeliveryPercentageText: '(3%)',
      rating: 4.6,
      status: DriverPerformanceDriverStatus.onTheWay,
    ),
    DriverPerformanceRecordEntity(
      driverId: 'dr_3',
      fullName: 'يوسف خالد',
      driverCode: 'DR-1018',
      deliveredCount: 24,
      deliveredPercentage: 86.0,
      deliveredCountText: '24',
      deliveredPercentageText: '(86%)',
      avgDelayMinutes: 15,
      delayLevel: DriverPerformanceDelayLevel.warning,
      failedDeliveryCount: 1,
      failedDeliveryPercentage: 3.5,
      failedDeliveryCountText: '1',
      failedDeliveryPercentageText: '(3.5%)',
      rating: 4.5,
      status: DriverPerformanceDriverStatus.available,
    ),
    DriverPerformanceRecordEntity(
      driverId: 'dr_4',
      fullName: 'فهد المطيري',
      driverCode: 'DR-1041',
      deliveredCount: 18,
      deliveredPercentage: 78.0,
      deliveredCountText: '18',
      deliveredPercentageText: '(78%)',
      avgDelayMinutes: 22,
      delayLevel: DriverPerformanceDelayLevel.critical,
      failedDeliveryCount: 2,
      failedDeliveryPercentage: 8.7,
      failedDeliveryCountText: '2',
      failedDeliveryPercentageText: '(8.7%)',
      rating: 4.1,
      status: DriverPerformanceDriverStatus.onTheWay,
    ),
    DriverPerformanceRecordEntity(
      driverId: 'dr_5',
      fullName: 'عبدالله الشهري',
      driverCode: 'DR-1007',
      deliveredCount: 10,
      deliveredPercentage: 62.0,
      deliveredCountText: '10',
      deliveredPercentageText: '(62%)',
      avgDelayMinutes: 35,
      delayLevel: DriverPerformanceDelayLevel.critical,
      failedDeliveryCount: 3,
      failedDeliveryPercentage: 18.7,
      failedDeliveryCountText: '3',
      failedDeliveryPercentageText: '(18.7%)',
      rating: 3.2,
      status: DriverPerformanceDriverStatus.onBreak,
    ),
  ];

  static const List<DriverPerformanceDistributionItemEntity> distribution = [
    DriverPerformanceDistributionItemEntity(
      id: 'dist_on_time',
      category: DriverPerformanceDistributionCategory.onTime,
      count: 79,
      percentage: 62,
    ),
    DriverPerformanceDistributionItemEntity(
      id: 'dist_late',
      category: DriverPerformanceDistributionCategory.late,
      count: 32,
      percentage: 25,
    ),
    DriverPerformanceDistributionItemEntity(
      id: 'dist_failed',
      category: DriverPerformanceDistributionCategory.failed,
      count: 11,
      percentage: 9,
    ),
    DriverPerformanceDistributionItemEntity(
      id: 'dist_cancelled',
      category: DriverPerformanceDistributionCategory.cancelled,
      count: 6,
      percentage: 4,
    ),
  ];

  static const List<DriverPodiumEntryEntity> topRatedDrivers = [
    DriverPodiumEntryEntity(rank: 1, name: 'أحمد السعيد', rating: 4.6),
    DriverPodiumEntryEntity(rank: 2, name: 'محمد العنزي', rating: 4.6),
    DriverPodiumEntryEntity(rank: 3, name: 'يوسف خالد', rating: 4.6),
  ];
}
