enum DriverOrdersFilter {
  all('All'),
  inProgress('InProgress'),
  delivered('Delivered'),
  failed('Failed');

  const DriverOrdersFilter(this.wireValue);

  final String wireValue;
}
