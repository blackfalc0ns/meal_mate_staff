import '../../domain/entities/driver_performance_period.dart';
import '../../domain/entities/driver_performance_sort_field.dart';
import '../../domain/entities/driver_performance_tab_type.dart';

sealed class DriverPerformanceEvent {
  const DriverPerformanceEvent();
}

class LoadDriverPerformanceOverviewEvent extends DriverPerformanceEvent {
  const LoadDriverPerformanceOverviewEvent();
}

class SelectDriverPerformanceTabEvent extends DriverPerformanceEvent {
  const SelectDriverPerformanceTabEvent(this.tab);

  final DriverPerformanceTabType tab;
}

class SelectDriverPerformancePeriodEvent extends DriverPerformanceEvent {
  const SelectDriverPerformancePeriodEvent(this.period);

  final DriverPerformancePeriod period;
}

class SelectDriverPerformanceCustomRangeEvent extends DriverPerformanceEvent {
  const SelectDriverPerformanceCustomRangeEvent({
    required this.fromDate,
    required this.toDate,
  });

  final DateTime fromDate;
  final DateTime toDate;
}

class RefreshDriverPerformanceEvent extends DriverPerformanceEvent {
  const RefreshDriverPerformanceEvent();
}

class RetryDriverPerformanceEvent extends DriverPerformanceEvent {
  const RetryDriverPerformanceEvent();
}

class SortDriverPerformanceTableEvent extends DriverPerformanceEvent {
  const SortDriverPerformanceTableEvent(this.field);

  final DriverPerformanceSortField field;
}
