enum DriverPerformancePeriod {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last7Days'),
  last30Days('Last30Days'),
  thisMonth('ThisMonth'),
  custom('Custom'),
  unknown('Unknown');

  const DriverPerformancePeriod(this.apiValue);

  final String apiValue;

  static DriverPerformancePeriod fromApi(String? value) {
    if (value == null) return DriverPerformancePeriod.unknown;
    final normalized = value.trim().toLowerCase();
    for (final period in DriverPerformancePeriod.values) {
      if (period.apiValue.toLowerCase() == normalized) {
        return period;
      }
    }
    return DriverPerformancePeriod.unknown;
  }
}
