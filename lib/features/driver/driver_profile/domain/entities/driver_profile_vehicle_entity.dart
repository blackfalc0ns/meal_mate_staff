class DriverProfileVehicleEntity {
  const DriverProfileVehicleEntity({
    this.vehicleType,
    this.vehicleTypeLocalized,
    this.vehicleModel,
    this.vehicleYear,
    this.color,
    this.vehicleColorLocalized,
    this.plateNumber,
    this.plateGovernorate,
    this.verificationStatus,
    this.verificationStatusText,
    this.isVehicleActive = false,
  });

  final String? vehicleType;
  final String? vehicleTypeLocalized;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? color;
  final String? vehicleColorLocalized;
  final String? plateNumber;
  final String? plateGovernorate;
  final String? verificationStatus;
  final String? verificationStatusText;
  final bool isVehicleActive;

  DriverProfileVehicleEntity copyWith({
    String? vehicleType,
    String? vehicleTypeLocalized,
    String? vehicleModel,
    int? vehicleYear,
    String? color,
    String? vehicleColorLocalized,
    String? plateNumber,
    String? plateGovernorate,
    String? verificationStatus,
    String? verificationStatusText,
    bool? isVehicleActive,
  }) {
    return DriverProfileVehicleEntity(
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleTypeLocalized: vehicleTypeLocalized ?? this.vehicleTypeLocalized,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      color: color ?? this.color,
      vehicleColorLocalized:
          vehicleColorLocalized ?? this.vehicleColorLocalized,
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
          vehicleTypeLocalized == other.vehicleTypeLocalized &&
          vehicleModel == other.vehicleModel &&
          vehicleYear == other.vehicleYear &&
          color == other.color &&
          vehicleColorLocalized == other.vehicleColorLocalized &&
          plateNumber == other.plateNumber &&
          plateGovernorate == other.plateGovernorate &&
          verificationStatus == other.verificationStatus &&
          verificationStatusText == other.verificationStatusText &&
          isVehicleActive == other.isVehicleActive;

  @override
  int get hashCode => Object.hash(
        vehicleType,
        vehicleTypeLocalized,
        vehicleModel,
        vehicleYear,
        color,
        vehicleColorLocalized,
        plateNumber,
        plateGovernorate,
        verificationStatus,
        verificationStatusText,
        isVehicleActive,
      );
}
