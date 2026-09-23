enum DriverPerformanceDriverStatus {
  available,
  onTheWay,
  onBreak,
  unknown;

  static DriverPerformanceDriverStatus fromApi(String? value) {
    if (value == null) return DriverPerformanceDriverStatus.unknown;
    switch (value.trim().toLowerCase()) {
      case 'available':
        return DriverPerformanceDriverStatus.available;
      case 'ontheway':
      case 'on_the_way':
        return DriverPerformanceDriverStatus.onTheWay;
      case 'onbreak':
      case 'on_break':
        return DriverPerformanceDriverStatus.onBreak;
      default:
        return DriverPerformanceDriverStatus.unknown;
    }
  }
}
