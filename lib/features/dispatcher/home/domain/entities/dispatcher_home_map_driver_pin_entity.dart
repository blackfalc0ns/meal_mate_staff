enum DispatcherHomePinStatus {
  inDelivery,
  onTheWayToLoad,
  paused,
}

class DispatcherHomeMapDriverPinEntity {
  const DispatcherHomeMapDriverPinEntity({
    required this.id,
    required this.boxCode,
    required this.statusText,
    required this.status,
    required this.avatarUrl,
    required this.relativeX,
    required this.relativeY,
  });

  final String id;
  final String boxCode;
  final String statusText;
  final DispatcherHomePinStatus status;
  final String avatarUrl;
  final double relativeX;
  final double relativeY;
}
