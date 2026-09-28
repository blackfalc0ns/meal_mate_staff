class DriverCurrentOrderEntity {
  const DriverCurrentOrderEntity({
    required this.orderId,
    required this.orderCode,
    required this.clientName,
    required this.address,
    required this.mealsCount,
    required this.deliveryTime,
    required this.imageAsset,
  });

  final String orderId;
  final String orderCode;
  final String clientName;
  final String address;
  final int mealsCount;
  final String deliveryTime;
  final String imageAsset;
}
