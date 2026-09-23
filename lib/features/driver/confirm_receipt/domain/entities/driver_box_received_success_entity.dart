class DriverBoxReceivedSuccessEntity {
  const DriverBoxReceivedSuccessEntity({
    required this.boxCode,
    required this.restaurantName,
    required this.itemsCount,
    required this.expectedReceiptTime,
    this.isReceived = true,
  });

  final String boxCode;
  final String restaurantName;
  final int itemsCount;
  final String expectedReceiptTime;
  final bool isReceived;
}
