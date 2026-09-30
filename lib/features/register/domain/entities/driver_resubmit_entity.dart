class DriverResubmitEntity {
  const DriverResubmitEntity({
    this.restaurantId,
    this.fullNameAr,
    this.fullNameEn,
    this.email,
    this.nationalId,
    this.nationalIdExpiry,
    this.dateOfBirth,
    this.nationality,
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleYear,
    this.vehicleColor,
    this.isVehicleOwned,
    this.licenseNumber,
    this.licenseExpiry,
    this.vehicleLicenseExpiry,
    this.contractExpiry,
    this.nationalIdFrontStorageKey,
    this.nationalIdBackStorageKey,
    this.drivingLicenseFrontStorageKey,
    this.drivingLicenseBackStorageKey,
    this.vehicleRegistrationStorageKey,
    this.profileImageStorageKey,
    this.vehiclePhotoStorageKey,
    this.contractStorageKey,
  });

  final String? restaurantId;
  final String? fullNameAr;
  final String? fullNameEn;
  final String? email;
  final String? nationalId;
  final String? nationalIdExpiry;
  final String? dateOfBirth;
  final String? nationality;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;
  final int? vehicleYear;
  final String? vehicleColor;
  final bool? isVehicleOwned;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? vehicleLicenseExpiry;
  final String? contractExpiry;
  final String? nationalIdFrontStorageKey;
  final String? nationalIdBackStorageKey;
  final String? drivingLicenseFrontStorageKey;
  final String? drivingLicenseBackStorageKey;
  final String? vehicleRegistrationStorageKey;
  final String? profileImageStorageKey;
  final String? vehiclePhotoStorageKey;
  final String? contractStorageKey;

  bool get isEmpty {
    return restaurantId == null &&
        fullNameAr == null &&
        fullNameEn == null &&
        email == null &&
        nationalId == null &&
        nationalIdExpiry == null &&
        dateOfBirth == null &&
        nationality == null &&
        vehicleType == null &&
        vehicleModel == null &&
        vehiclePlate == null &&
        vehicleYear == null &&
        vehicleColor == null &&
        isVehicleOwned == null &&
        licenseNumber == null &&
        licenseExpiry == null &&
        vehicleLicenseExpiry == null &&
        contractExpiry == null &&
        nationalIdFrontStorageKey == null &&
        nationalIdBackStorageKey == null &&
        drivingLicenseFrontStorageKey == null &&
        drivingLicenseBackStorageKey == null &&
        vehicleRegistrationStorageKey == null &&
        profileImageStorageKey == null &&
        vehiclePhotoStorageKey == null &&
        contractStorageKey == null;
  }

  bool get isNotEmpty => !isEmpty;
}
