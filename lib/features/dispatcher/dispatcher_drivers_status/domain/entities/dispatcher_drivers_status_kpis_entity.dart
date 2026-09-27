class DispatcherDriversStatusKpisEntity {
  const DispatcherDriversStatusKpisEntity({
    required this.connectedCount,
    required this.inDeliveryCount,
    required this.offlineCount,
    required this.totalCount,
  });

  final int connectedCount;
  final int inDeliveryCount;
  final int offlineCount;
  final int totalCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversStatusKpisEntity &&
          runtimeType == other.runtimeType &&
          connectedCount == other.connectedCount &&
          inDeliveryCount == other.inDeliveryCount &&
          offlineCount == other.offlineCount &&
          totalCount == other.totalCount;

  @override
  int get hashCode => Object.hash(
    connectedCount,
    inDeliveryCount,
    offlineCount,
    totalCount,
  );
}
