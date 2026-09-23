import 'driver_performance_record_entity.dart';

enum DriverPerformanceSortField {
  driver,
  delivered,
  avgDelay,
  failedDelivery,
  rating,
}

extension DriverPerformanceRecordListSort
    on List<DriverPerformanceRecordEntity> {
  List<DriverPerformanceRecordEntity> sortedByField(
    DriverPerformanceSortField field, {
    required bool ascending,
  }) {
    final copy = List<DriverPerformanceRecordEntity>.from(this);
    copy.sort((a, b) {
      final int cmp;
      switch (field) {
        case DriverPerformanceSortField.driver:
          cmp = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
        case DriverPerformanceSortField.delivered:
          cmp = a.deliveredCount.compareTo(b.deliveredCount);
        case DriverPerformanceSortField.avgDelay:
          cmp = a.avgDelayMinutes.compareTo(b.avgDelayMinutes);
        case DriverPerformanceSortField.failedDelivery:
          cmp = a.failedDeliveryCount.compareTo(b.failedDeliveryCount);
        case DriverPerformanceSortField.rating:
          cmp = a.rating.compareTo(b.rating);
      }
      return ascending ? cmp : -cmp;
    });
    return copy;
  }
}
