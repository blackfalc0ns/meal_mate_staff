enum DriverPerformanceDistributionCategory {
  onTime,
  late,
  failed,
  cancelled,
  unknown;

  static DriverPerformanceDistributionCategory fromApi(String? value) {
    if (value == null) return DriverPerformanceDistributionCategory.unknown;
    switch (value.trim().toLowerCase()) {
      case 'ontime':
      case 'on_time':
        return DriverPerformanceDistributionCategory.onTime;
      case 'delayed':
      case 'late':
        return DriverPerformanceDistributionCategory.late;
      case 'failed':
        return DriverPerformanceDistributionCategory.failed;
      case 'cancelled':
      case 'canceled':
        return DriverPerformanceDistributionCategory.cancelled;
      default:
        return DriverPerformanceDistributionCategory.unknown;
    }
  }
}
