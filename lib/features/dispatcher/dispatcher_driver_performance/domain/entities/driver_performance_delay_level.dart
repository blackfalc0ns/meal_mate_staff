enum DriverPerformanceDelayLevel { good, warning, critical, unknown }

extension DriverPerformanceDelayLevelX on DriverPerformanceDelayLevel {
  static DriverPerformanceDelayLevel fromApi(String? value) {
    if (value == null) return DriverPerformanceDelayLevel.unknown;
    switch (value.trim().toLowerCase()) {
      case 'good':
        return DriverPerformanceDelayLevel.good;
      case 'warning':
        return DriverPerformanceDelayLevel.warning;
      case 'critical':
        return DriverPerformanceDelayLevel.critical;
      default:
        return DriverPerformanceDelayLevel.unknown;
    }
  }
}
