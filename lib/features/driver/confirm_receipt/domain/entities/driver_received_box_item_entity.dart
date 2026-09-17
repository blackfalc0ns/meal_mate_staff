class DriverReceivedBoxItemEntity {
  const DriverReceivedBoxItemEntity({
    required this.indexNumber,
    required this.boxCode,
    required this.condition,
    this.isReceived = true,
  });

  final int indexNumber;
  final String boxCode;
  final String condition;
  final bool isReceived;
}
