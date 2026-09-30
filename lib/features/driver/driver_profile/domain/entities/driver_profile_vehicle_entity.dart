class DriverProfileVehicleEntity {
  const DriverProfileVehicleEntity({
    this.vehicleType,
    this.vehicleModel,
    this.vehicleYear,
    this.color,
    this.plateNumber,
    this.plateGovernorate,
    this.verificationStatus,
    this.verificationStatusText,
    this.isVehicleActive = false,
  });

  final String? vehicleType;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? color;
  final String? plateNumber;
  final String? plateGovernorate;
  final String? verificationStatus;
  final String? verificationStatusText;
  final bool isVehicleActive;

  DriverProfileVehicleEntity copyWith({
    String? vehicleType,
    String? vehicleModel,
    int? vehicleYear,
    String? color,
    String? plateNumber,
    String? plateGovernorate,
    String? verificationStatus,
    String? verificationStatusText,
    bool? isVehicleActive,
  }) {
    return DriverProfileVehicleEntity(
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      plateGovernorate: plateGovernorate ?? this.plateGovernorate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationStatusText:
          verificationStatusText ?? this.verificationStatusText,
      isVehicleActive: isVehicleActive ?? this.isVehicleActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileVehicleEntity &&
          runtimeType == other.runtimeType &&
          vehicleType == other.vehicleType &&
          vehicleModel == other.vehicleModel &&
          vehicleYear == other.vehicleYear &&
          color == other.color &&
          plateNumber == other.plateNumber &&
          plateGovernorate == other.plateGovernorate &&
          verificationStatus == other.verificationStatus &&
          verificationStatusText == other.verificationStatusText &&
          isVehicleActive == other.isVehicleActive;

  @override
  int get hashCode => Object.hash(
        vehicleType,
        vehicleModel,
        vehicleYear,
        color,
        plateNumber,
        plateGovernorate,
        verificationStatus,
        verificationStatusText,
        isVehicleActive,
      );
}
