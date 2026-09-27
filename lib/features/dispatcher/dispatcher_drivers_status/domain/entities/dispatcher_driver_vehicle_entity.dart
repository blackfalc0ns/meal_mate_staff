class DispatcherDriverVehicleEntity {
  const DispatcherDriverVehicleEntity({
    this.model = '',
    this.colorName = '',
    this.plateNumber = '',
    this.imageAsset = '',
    this.vehicleType = '',
  });

  final String model;
  final String colorName;
  final String plateNumber;
  final String imageAsset;
  final String vehicleType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverVehicleEntity &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          colorName == other.colorName &&
          plateNumber == other.plateNumber &&
          imageAsset == other.imageAsset &&
          vehicleType == other.vehicleType;

  @override
  int get hashCode =>
      Object.hash(model, colorName, plateNumber, imageAsset, vehicleType);
}
