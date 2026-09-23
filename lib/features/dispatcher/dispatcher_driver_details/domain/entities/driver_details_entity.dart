import 'driver_daily_summary_entity.dart';
import 'driver_kpis_entity.dart';
import 'driver_profile_entity.dart';

class DriverDetailsEntity {
  const DriverDetailsEntity({
    required this.driver,
    required this.kpis,
    required this.dailySummary,
  });

  final DriverProfileEntity driver;
  final DriverKpisEntity kpis;
  final DriverDailySummaryEntity dailySummary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverDetailsEntity &&
          runtimeType == other.runtimeType &&
          driver == other.driver &&
          kpis == other.kpis &&
          dailySummary == other.dailySummary;

  @override
  int get hashCode => Object.hash(driver, kpis, dailySummary);
}
