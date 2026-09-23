class ActiveDeliveryOrderEntity {
  const ActiveDeliveryOrderEntity({
    required this.orderId,
    required this.boxCode,
    required this.customerName,
    required this.customerPhone,
    required this.customerAvatar,
    required this.address,
    required this.mealsCount,
    required this.customerNote,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.paymentMethod,
  });

  final String orderId;
  final String boxCode;
  final String customerName;
  final String customerPhone;
  final String customerAvatar;
  final String address;
  final int mealsCount;
  final String customerNote;
  final String restaurantName;
  final String restaurantAddress;
  final String paymentMethod;
}
