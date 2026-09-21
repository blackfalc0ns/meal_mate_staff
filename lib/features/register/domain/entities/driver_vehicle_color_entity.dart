class DriverVehicleColorEntity {
  const DriverVehicleColorEntity({
    required this.hex,
    required this.nameAr,
    required this.nameEn,
    required this.isDefault,
    required this.displayOrder,
  });

  final String hex;
  final String nameAr;
  final String nameEn;
  final bool isDefault;
  final int displayOrder;
}
