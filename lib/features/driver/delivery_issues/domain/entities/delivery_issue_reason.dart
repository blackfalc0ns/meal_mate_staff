enum DeliveryIssueReason {
  // Existing values kept for UI compatibility
  customerNoAnswer,
  addressUnclear,
  severeDelay,
  boxDamaged,
  refusedDelivery,

  // Canonical contract values
  addressIssue,
  roadIssue,
  vehicleBreakdown,
  trafficAccident,
  severeWeather,
  customerUnavailable,
  customerRefusal,
  damagedBox,
  other;

  String get wireValue => switch (this) {
    DeliveryIssueReason.addressUnclear ||
    DeliveryIssueReason.addressIssue =>
      'AddressIssue',
    DeliveryIssueReason.severeDelay => 'SevereDelay',
    DeliveryIssueReason.roadIssue => 'RoadIssue',
    DeliveryIssueReason.vehicleBreakdown => 'VehicleBreakdown',
    DeliveryIssueReason.trafficAccident => 'TrafficAccident',
    DeliveryIssueReason.severeWeather => 'SevereWeather',
    DeliveryIssueReason.customerNoAnswer ||
    DeliveryIssueReason.customerUnavailable =>
      'CustomerUnavailable',
    DeliveryIssueReason.refusedDelivery ||
    DeliveryIssueReason.customerRefusal =>
      'CustomerRefusal',
    DeliveryIssueReason.boxDamaged ||
    DeliveryIssueReason.damagedBox =>
      'DamagedBox',
    DeliveryIssueReason.other => 'Other',
  };
}
