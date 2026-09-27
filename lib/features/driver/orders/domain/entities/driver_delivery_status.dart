enum DriverDeliveryStatus {
  pending,
  inProgress,
  arrivedAtCustomer,
  delivered,
  failed,
  reassignmentRequested,
  unknown;

  bool get isProblem =>
      this == DriverDeliveryStatus.failed ||
      this == DriverDeliveryStatus.reassignmentRequested;

  bool get isCompleted => this == DriverDeliveryStatus.delivered;

  bool get isActive =>
      this == DriverDeliveryStatus.inProgress ||
      this == DriverDeliveryStatus.arrivedAtCustomer;
}

extension DriverDeliveryStatusX on DriverDeliveryStatus {
  static DriverDeliveryStatus fromWire(String? value) {
    if (value == null) return DriverDeliveryStatus.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'pending':
        return DriverDeliveryStatus.pending;
      case 'inprogress':
        return DriverDeliveryStatus.inProgress;
      case 'arrivedatcustomer':
        return DriverDeliveryStatus.arrivedAtCustomer;
      case 'delivered':
        return DriverDeliveryStatus.delivered;
      case 'failed':
        return DriverDeliveryStatus.failed;
      case 'reassignmentrequested':
        return DriverDeliveryStatus.reassignmentRequested;
      default:
        return DriverDeliveryStatus.unknown;
    }
  }
}
