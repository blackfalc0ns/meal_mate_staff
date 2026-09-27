enum DispatcherDriverStatusType {
  available,
  inDelivery,
  unavailable,
  unknown;

  static DispatcherDriverStatusType fromApi(String? value) {
    if (value == null) return DispatcherDriverStatusType.unknown;
    switch (value.trim().toLowerCase()) {
      case 'available':
        return DispatcherDriverStatusType.available;
      case 'indelivery':
      case 'in_delivery':
      case 'in-delivery':
        return DispatcherDriverStatusType.inDelivery;
      case 'unavailable':
      case 'offline':
        return DispatcherDriverStatusType.unavailable;
      default:
        return DispatcherDriverStatusType.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case DispatcherDriverStatusType.available:
        return 'Available';
      case DispatcherDriverStatusType.inDelivery:
        return 'InDelivery';
      case DispatcherDriverStatusType.unavailable:
        return 'Unavailable';
      case DispatcherDriverStatusType.unknown:
        return 'All';
    }
  }
}
