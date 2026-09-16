class DriverActiveBoxEntity {
  const DriverActiveBoxEntity({
    required this.boxId,
    required this.customerName,
    required this.area,
    required this.status,
    required this.time,
    required this.imageAsset,
    this.isDelivering = true,
  });

  final String boxId;
  final String customerName;
  final String area;
  final String status;
  final String time;
  final String imageAsset;
  final bool isDelivering;
}
