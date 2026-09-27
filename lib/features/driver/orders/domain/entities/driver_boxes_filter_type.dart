enum DriverBoxesFilterType {
  all('All'),
  pendingScan('PendingScan'),
  pickedUp('PickedUp');

  const DriverBoxesFilterType(this.wireValue);
  final String wireValue;
}
