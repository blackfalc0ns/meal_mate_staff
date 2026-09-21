class RegisterVehicleData {
  const RegisterVehicleData({
    required this.type,
    required this.model,
    required this.manufactureYear,
    required this.plateNumber,
    required this.country,
    required this.color,
    required this.isOwned,
    this.licenseNumber = '',
    this.licenseExpiry = '',
    this.vehicleLicenseExpiry = '',
    this.contractExpiry,
  });

  static const empty = RegisterVehicleData(
    type: '',
    model: '',
    manufactureYear: '',
    plateNumber: '',
    country: '',
    color: '',
    isOwned: true,
  );

  final String type;
  final String model;
  final String manufactureYear;
  final String plateNumber;
  final String country;
  final String color;
  final bool isOwned;
  final String licenseNumber;
  final String licenseExpiry;
  final String vehicleLicenseExpiry;
  final String? contractExpiry;

  RegisterVehicleData copyWith({
    String? type,
    String? model,
    String? manufactureYear,
    String? plateNumber,
    String? country,
    String? color,
    bool? isOwned,
    String? licenseNumber,
    String? licenseExpiry,
    String? vehicleLicenseExpiry,
    String? contractExpiry,
    bool clearContractExpiry = false,
  }) {
    return RegisterVehicleData(
      type: type ?? this.type,
      model: model ?? this.model,
      manufactureYear: manufactureYear ?? this.manufactureYear,
      plateNumber: plateNumber ?? this.plateNumber,
      country: country ?? this.country,
      color: color ?? this.color,
      isOwned: isOwned ?? this.isOwned,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      vehicleLicenseExpiry: vehicleLicenseExpiry ?? this.vehicleLicenseExpiry,
      contractExpiry: clearContractExpiry
          ? null
          : (contractExpiry ?? this.contractExpiry),
    );
  }
}
