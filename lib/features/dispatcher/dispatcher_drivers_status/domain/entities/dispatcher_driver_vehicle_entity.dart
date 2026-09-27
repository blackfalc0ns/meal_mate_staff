class DispatcherDriverVehicleEntity {
  const DispatcherDriverVehicleEntity({
    required this.model,
    required this.colorName,
    required this.plateNumber,
    required this.imageAsset,
  });

  final String model;
  final String colorName;
  final String plateNumber;
  final String imageAsset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverVehicleEntity &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          colorName == other.colorName &&
          plateNumber == other.plateNumber &&
          imageAsset == other.imageAsset;

  @override
  int get hashCode => Object.hash(model, colorName, plateNumber, imageAsset);
}
