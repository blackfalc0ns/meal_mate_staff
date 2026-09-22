class DispatcherIssueTripEntity {
  const DispatcherIssueTripEntity({
    required this.clientName,
    required this.mealsCount,
    required this.expectedDeliveryTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.orderId,
  });

  final String clientName;
  final int mealsCount;
  final String expectedDeliveryTime;
  final String pickupLocation;
  final String dropoffLocation;
  final String? orderId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherIssueTripEntity &&
          runtimeType == other.runtimeType &&
          clientName == other.clientName &&
          mealsCount == other.mealsCount &&
          expectedDeliveryTime == other.expectedDeliveryTime &&
          pickupLocation == other.pickupLocation &&
          dropoffLocation == other.dropoffLocation;

  @override
  int get hashCode => Object.hash(
        clientName,
        mealsCount,
        expectedDeliveryTime,
        pickupLocation,
        dropoffLocation,
      );
}
