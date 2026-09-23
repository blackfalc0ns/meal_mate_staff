class DriverActiveBoxEntity {
  const DriverActiveBoxEntity({
    required this.boxId,
    required this.boxCode,
    required this.customerName,
    required this.deliveryAddress,
    required this.status,
    required this.statusText,
    this.statusColor,
    required this.scheduledTimeText,
    this.isDelivering = false,
  });

  final String boxId;
  final String boxCode;
  final String customerName;
  final String deliveryAddress;
  final String status;
  final String statusText;
  final String? statusColor;
  final String scheduledTimeText;
  final bool isDelivering;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverActiveBoxEntity &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          boxCode == other.boxCode &&
          customerName == other.customerName &&
          deliveryAddress == other.deliveryAddress &&
          status == other.status &&
          statusText == other.statusText &&
          statusColor == other.statusColor &&
          scheduledTimeText == other.scheduledTimeText &&
          isDelivering == other.isDelivering;

  @override
  int get hashCode => Object.hash(
        boxId,
        boxCode,
        customerName,
        deliveryAddress,
        status,
        statusText,
        statusColor,
        scheduledTimeText,
        isDelivering,
      );
}
