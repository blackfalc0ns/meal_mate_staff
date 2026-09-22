enum DispatcherSupportDatePreset {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last7Days'),
  last30Days('Last30Days'),
  custom('Custom');

  const DispatcherSupportDatePreset(this.apiValue);

  final String apiValue;
}
