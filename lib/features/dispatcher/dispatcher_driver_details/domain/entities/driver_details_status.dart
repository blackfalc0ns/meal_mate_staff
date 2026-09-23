enum DriverDetailsStatus {
  available,
  busy,
  delivering,
  onDelivery,
  offline,
  inBreak,
  unknown,
}

extension DriverDetailsStatusX on DriverDetailsStatus {
  static DriverDetailsStatus fromApi(String? value) {
    if (value == null) return DriverDetailsStatus.unknown;
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '');
    switch (normalized) {
      case 'available':
        return DriverDetailsStatus.available;
      case 'busy':
        return DriverDetailsStatus.busy;
      case 'delivering':
      case 'indelivery':
        return DriverDetailsStatus.delivering;
      case 'ondelivery':
        return DriverDetailsStatus.onDelivery;
      case 'offline':
        return DriverDetailsStatus.offline;
      case 'inbreak':
      case 'break':
        return DriverDetailsStatus.inBreak;
      default:
        return DriverDetailsStatus.unknown;
    }
  }

  bool get isAvailable => this == DriverDetailsStatus.available;
  bool get isOffline => this == DriverDetailsStatus.offline;
  bool get isDelivering =>
      this == DriverDetailsStatus.delivering ||
      this == DriverDetailsStatus.onDelivery;
}
