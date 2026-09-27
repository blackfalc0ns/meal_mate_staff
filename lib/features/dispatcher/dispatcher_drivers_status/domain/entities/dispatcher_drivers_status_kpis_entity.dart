class DispatcherDriversStatusKpisEntity {
  const DispatcherDriversStatusKpisEntity({
    required this.total,
    required this.available,
    required this.inDelivery,
    required this.unavailable,
  });

  final int total;
  final int available;
  final int inDelivery;
  final int unavailable;

  // Backward compatibility getters
  int get totalCount => total;
  int get connectedCount => available;
  int get inDeliveryCount => inDelivery;
  int get offlineCount => unavailable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversStatusKpisEntity &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          available == other.available &&
          inDelivery == other.inDelivery &&
          unavailable == other.unavailable;

  @override
  int get hashCode => Object.hash(total, available, inDelivery, unavailable);
}
