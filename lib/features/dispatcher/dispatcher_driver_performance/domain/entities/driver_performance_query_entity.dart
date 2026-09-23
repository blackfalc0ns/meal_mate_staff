import 'driver_performance_period.dart';

class DriverPerformanceQueryEntity {
  const DriverPerformanceQueryEntity({
    this.period = DriverPerformancePeriod.last7Days,
    this.fromDate,
    this.toDate,
    this.driverIds,
  });

  final DriverPerformancePeriod period;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<String>? driverIds;

  bool get isValid {
    if (period == DriverPerformancePeriod.custom) {
      if (fromDate == null || toDate == null) return false;
      if (fromDate!.isAfter(toDate!)) return false;
    }
    return true;
  }

  String? get fromDateFormatted {
    if (period != DriverPerformancePeriod.custom || fromDate == null) {
      return null;
    }
    return _formatDate(fromDate!);
  }

  String? get toDateFormatted {
    if (period != DriverPerformancePeriod.custom || toDate == null) {
      return null;
    }
    return _formatDate(toDate!);
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DriverPerformanceQueryEntity copyWith({
    DriverPerformancePeriod? period,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? driverIds,
    bool clearDates = false,
  }) {
    return DriverPerformanceQueryEntity(
      period: period ?? this.period,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
      driverIds: driverIds ?? this.driverIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverPerformanceQueryEntity &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          fromDate == other.fromDate &&
          toDate == other.toDate;

  @override
  int get hashCode => Object.hash(period, fromDate, toDate);
}
