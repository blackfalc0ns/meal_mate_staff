import '../register_personal_data.dart';
import '../register_vehicle_data.dart';

class DriverRegistrationDraftEntity {
  const DriverRegistrationDraftEntity({
    this.restaurantId = '',
    this.restaurantName = '',
    this.fullNameAr = '',
    this.fullNameEn = '',
    this.phone = '',
    this.email,
    this.nationalId = '',
    this.nationalIdExpiry = '',
    this.dateOfBirth,
    this.nationality = '',
    this.vehicleType = 'Car',
    this.vehicleModel = '',
    this.vehiclePlate = '',
    this.vehicleYear = 2024,
    this.vehicleColor,
    this.isVehicleOwned = true,
    this.licenseNumber = '',
    this.licenseExpiry = '',
    this.vehicleLicenseExpiry = '',
    this.contractExpiry,
    this.nationalIdFrontStorageKey = '',
    this.nationalIdBackStorageKey = '',
    this.drivingLicenseFrontStorageKey = '',
    this.drivingLicenseBackStorageKey = '',
    this.vehicleRegistrationStorageKey = '',
    this.profileImageStorageKey,
    this.vehiclePhotoStorageKey,
    this.contractStorageKey,
  });

  final String restaurantId;
  final String restaurantName;
  final String fullNameAr;
  final String fullNameEn;
  final String phone;
  final String? email;
  final String nationalId;
  final String nationalIdExpiry;
  final String? dateOfBirth;
  final String nationality;
  final String vehicleType;
  final String vehicleModel;
  final String vehiclePlate;
  final int vehicleYear;
  final String? vehicleColor;
  final bool isVehicleOwned;
  final String licenseNumber;
  final String licenseExpiry;
  final String vehicleLicenseExpiry;
  final String? contractExpiry;
  final String nationalIdFrontStorageKey;
  final String nationalIdBackStorageKey;
  final String drivingLicenseFrontStorageKey;
  final String drivingLicenseBackStorageKey;
  final String vehicleRegistrationStorageKey;
  final String? profileImageStorageKey;
  final String? vehiclePhotoStorageKey;
  final String? contractStorageKey;

  bool get hasRequiredPersonalData =>
      restaurantId.trim().isNotEmpty &&
      fullNameAr.trim().isNotEmpty &&
      fullNameEn.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      nationalId.trim().isNotEmpty &&
      nationalIdExpiry.trim().isNotEmpty &&
      nationality.trim().isNotEmpty;

  bool get hasRequiredVehicleData =>
      vehicleType.trim().isNotEmpty &&
      vehicleModel.trim().isNotEmpty &&
      vehiclePlate.trim().isNotEmpty &&
      vehicleYear > 1900 &&
      licenseNumber.trim().isNotEmpty &&
      licenseExpiry.trim().isNotEmpty &&
      vehicleLicenseExpiry.trim().isNotEmpty;

  bool get hasRequiredDocuments =>
      nationalIdFrontStorageKey.trim().isNotEmpty &&
      nationalIdBackStorageKey.trim().isNotEmpty &&
      drivingLicenseFrontStorageKey.trim().isNotEmpty &&
      drivingLicenseBackStorageKey.trim().isNotEmpty &&
      vehicleRegistrationStorageKey.trim().isNotEmpty;

  bool get isReadyForSubmission =>
      hasRequiredPersonalData &&
      hasRequiredVehicleData &&
      hasRequiredDocuments;

  RegisterPersonalData toPersonalData() {
    final names = fullNameEn.isNotEmpty ? fullNameEn.split(' ') : <String>[];
    final first = names.isNotEmpty ? names.first : '';
    final last = names.length > 1 ? names.sublist(1).join(' ') : '';
    return RegisterPersonalData(
      firstName: first,
      lastName: last,
      phone: phone,
      email: email ?? '',
      birthDate: dateOfBirth ?? '',
      nationality: nationality,
      civilId: nationalId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      fullNameAr: fullNameAr,
      fullNameEn: fullNameEn,
      nationalIdExpiry: nationalIdExpiry,
    );
  }

  RegisterVehicleData toVehicleData() {
    return RegisterVehicleData(
      type: vehicleType,
      model: vehicleModel,
      manufactureYear: vehicleYear.toString(),
      plateNumber: vehiclePlate,
      country: '',
      color: vehicleColor ?? '',
      isOwned: isVehicleOwned,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      vehicleLicenseExpiry: vehicleLicenseExpiry,
      contractExpiry: contractExpiry,
    );
  }

  DriverRegistrationDraftEntity copyWith({
    String? restaurantId,
    String? restaurantName,
    String? fullNameAr,
    String? fullNameEn,
    String? phone,
    String? email,
    String? nationalId,
    String? nationalIdExpiry,
    String? dateOfBirth,
    String? nationality,
    String? vehicleType,
    String? vehicleModel,
    String? vehiclePlate,
    int? vehicleYear,
    String? vehicleColor,
    bool? isVehicleOwned,
    String? licenseNumber,
    String? licenseExpiry,
    String? vehicleLicenseExpiry,
    String? contractExpiry,
    String? nationalIdFrontStorageKey,
    String? nationalIdBackStorageKey,
    String? drivingLicenseFrontStorageKey,
    String? drivingLicenseBackStorageKey,
    String? vehicleRegistrationStorageKey,
    String? profileImageStorageKey,
    String? vehiclePhotoStorageKey,
    String? contractStorageKey,
  }) {
    return DriverRegistrationDraftEntity(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      nationalIdExpiry: nationalIdExpiry ?? this.nationalIdExpiry,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      isVehicleOwned: isVehicleOwned ?? this.isVehicleOwned,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      vehicleLicenseExpiry:
          vehicleLicenseExpiry ?? this.vehicleLicenseExpiry,
      contractExpiry: contractExpiry ?? this.contractExpiry,
      nationalIdFrontStorageKey:
          nationalIdFrontStorageKey ?? this.nationalIdFrontStorageKey,
      nationalIdBackStorageKey:
          nationalIdBackStorageKey ?? this.nationalIdBackStorageKey,
      drivingLicenseFrontStorageKey:
          drivingLicenseFrontStorageKey ?? this.drivingLicenseFrontStorageKey,
      drivingLicenseBackStorageKey:
          drivingLicenseBackStorageKey ?? this.drivingLicenseBackStorageKey,
      vehicleRegistrationStorageKey:
          vehicleRegistrationStorageKey ?? this.vehicleRegistrationStorageKey,
      profileImageStorageKey:
          profileImageStorageKey ?? this.profileImageStorageKey,
      vehiclePhotoStorageKey:
          vehiclePhotoStorageKey ?? this.vehiclePhotoStorageKey,
      contractStorageKey: contractStorageKey ?? this.contractStorageKey,
    );
  }
}
