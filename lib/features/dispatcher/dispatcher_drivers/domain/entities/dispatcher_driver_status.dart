enum DispatcherDriverStatus {
  available,
  busy,
  onTheWay,
  onBreak,
  unknown;

  String get apiValue {
    switch (this) {
      case DispatcherDriverStatus.available:
        return 'Available';
      case DispatcherDriverStatus.busy:
        return 'Busy';
      case DispatcherDriverStatus.onTheWay:
        return 'OnTheWay';
      case DispatcherDriverStatus.onBreak:
        return 'OnBreak';
      case DispatcherDriverStatus.unknown:
        return 'Unknown';
    }
  }
}

extension DispatcherDriverStatusX on DispatcherDriverStatus {
  static DispatcherDriverStatus fromApi(String? value) {
    if (value == null) return DispatcherDriverStatus.unknown;
    switch (value.trim().toLowerCase()) {
      case 'available':
        return DispatcherDriverStatus.available;
      case 'busy':
        return DispatcherDriverStatus.busy;
      case 'ontheway':
      case 'indelivery':
      case 'delivering':
        return DispatcherDriverStatus.busy;
      case 'onbreak':
      case 'break':
        return DispatcherDriverStatus.onBreak;
      default:
        return DispatcherDriverStatus.unknown;
    }
  }
}
