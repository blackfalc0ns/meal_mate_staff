class DriverVehicleEntity {
  const DriverVehicleEntity({
    required this.brandAndModel,
    required this.model,
    required this.colorName,
    required this.manufactureYear,
    required this.bodyType,
    required this.plateNumber,
    required this.plateLetter,
    required this.plateLetterEn,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.imageAsset,
    this.notes = '',
  });

  final String brandAndModel;
  final String model;
  final String colorName;
  final String manufactureYear;
  final String bodyType;
  final String plateNumber;
  final String plateLetter;
  final String plateLetterEn;
  final String licenseNumber;
  final String licenseExpiryDate;
  final String imageAsset;
  final String notes;

  DriverVehicleEntity copyWith({
    String? brandAndModel,
    String? model,
    String? colorName,
    String? manufactureYear,
    String? bodyType,
    String? plateNumber,
    String? plateLetter,
    String? plateLetterEn,
    String? licenseNumber,
    String? licenseExpiryDate,
    String? imageAsset,
    String? notes,
  }) {
    return DriverVehicleEntity(
      brandAndModel: brandAndModel ?? this.brandAndModel,
      model: model ?? this.model,
      colorName: colorName ?? this.colorName,
      manufactureYear: manufactureYear ?? this.manufactureYear,
      bodyType: bodyType ?? this.bodyType,
      plateNumber: plateNumber ?? this.plateNumber,
      plateLetter: plateLetter ?? this.plateLetter,
      plateLetterEn: plateLetterEn ?? this.plateLetterEn,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      imageAsset: imageAsset ?? this.imageAsset,
      notes: notes ?? this.notes,
    );
  }
}
