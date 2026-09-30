import '../register_personal_data.dart';
import '../register_vehicle_data.dart';
import 'driver_resubmit_entity.dart';

class DriverRegistrationDraftEntity {
  const DriverRegistrationDraftEntity({
    this.restaurantId = '',
    this.restaurantName = '',
    this.fullNameAr = '',
    this.fullNameEn = '',
    this.phone = '',
    this.password = '',
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
  final String password;
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
      fullNameAr.trim().isNotEmpty &&
      fullNameEn.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
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
      hasRequiredPersonalData && hasRequiredVehicleData && hasRequiredDocuments;

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
      password: password,
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

  DriverResubmitEntity toResubmitEntity() {
    return DriverResubmitEntity(
      restaurantId: restaurantId.isNotEmpty ? restaurantId : null,
      fullNameAr: fullNameAr.isNotEmpty ? fullNameAr : null,
      fullNameEn: fullNameEn.isNotEmpty ? fullNameEn : null,
      email: email,
      nationalId: nationalId.isNotEmpty ? nationalId : null,
      nationalIdExpiry: nationalIdExpiry.isNotEmpty ? nationalIdExpiry : null,
      dateOfBirth: dateOfBirth,
      nationality: nationality.isNotEmpty ? nationality : null,
      vehicleType: vehicleType.isNotEmpty ? vehicleType : null,
      vehicleModel: vehicleModel.isNotEmpty ? vehicleModel : null,
      vehiclePlate: vehiclePlate.isNotEmpty ? vehiclePlate : null,
      vehicleYear: vehicleYear > 0 ? vehicleYear : null,
      vehicleColor: vehicleColor,
      isVehicleOwned: isVehicleOwned,
      licenseNumber: licenseNumber.isNotEmpty ? licenseNumber : null,
      licenseExpiry: licenseExpiry.isNotEmpty ? licenseExpiry : null,
      vehicleLicenseExpiry: vehicleLicenseExpiry.isNotEmpty
          ? vehicleLicenseExpiry
          : null,
      contractExpiry: contractExpiry,
      nationalIdFrontStorageKey: nationalIdFrontStorageKey.isNotEmpty
          ? nationalIdFrontStorageKey
          : null,
      nationalIdBackStorageKey: nationalIdBackStorageKey.isNotEmpty
          ? nationalIdBackStorageKey
          : null,
      drivingLicenseFrontStorageKey: drivingLicenseFrontStorageKey.isNotEmpty
          ? drivingLicenseFrontStorageKey
          : null,
      drivingLicenseBackStorageKey: drivingLicenseBackStorageKey.isNotEmpty
          ? drivingLicenseBackStorageKey
          : null,
      vehicleRegistrationStorageKey: vehicleRegistrationStorageKey.isNotEmpty
          ? vehicleRegistrationStorageKey
          : null,
      profileImageStorageKey: profileImageStorageKey,
      vehiclePhotoStorageKey: vehiclePhotoStorageKey,
      contractStorageKey: contractStorageKey,
    );
  }

  bool hasChangesFrom({
    required DriverRegistrationDraftEntity original,
    Set<String> newlyUploadedDocumentIds = const {},
  }) {
    if (newlyUploadedDocumentIds.isNotEmpty) return true;
    if (restaurantId.trim() != original.restaurantId.trim()) return true;
    if (fullNameAr.trim() != original.fullNameAr.trim()) return true;
    if (fullNameEn.trim() != original.fullNameEn.trim()) return true;
    if (email?.trim() != original.email?.trim()) return true;
    if (nationalId.trim() != original.nationalId.trim()) return true;
    if (nationalIdExpiry.trim() != original.nationalIdExpiry.trim()) return true;
    if (dateOfBirth?.trim() != original.dateOfBirth?.trim()) return true;
    if (nationality.trim() != original.nationality.trim()) return true;
    if (vehicleType.trim() != original.vehicleType.trim()) return true;
    if (vehicleModel.trim() != original.vehicleModel.trim()) return true;
    if (vehiclePlate.trim() != original.vehiclePlate.trim()) return true;
    if (vehicleYear != original.vehicleYear) return true;
    if (vehicleColor?.trim() != original.vehicleColor?.trim()) return true;
    if (isVehicleOwned != original.isVehicleOwned) return true;
    if (licenseNumber.trim() != original.licenseNumber.trim()) return true;
    if (licenseExpiry.trim() != original.licenseExpiry.trim()) return true;
    if (vehicleLicenseExpiry.trim() != original.vehicleLicenseExpiry.trim()) {
      return true;
    }
    if (contractExpiry?.trim() != original.contractExpiry?.trim()) return true;
    return false;
  }

  DriverResubmitEntity toSparseResubmitEntity({
    required DriverRegistrationDraftEntity original,
    Set<String> newlyUploadedDocumentIds = const {},
  }) {
    return DriverResubmitEntity(
      restaurantId: restaurantId.trim() != original.restaurantId.trim()
          ? (restaurantId.trim().isNotEmpty ? restaurantId.trim() : null)
          : null,
      fullNameAr: fullNameAr.trim() != original.fullNameAr.trim()
          ? (fullNameAr.trim().isNotEmpty ? fullNameAr.trim() : null)
          : null,
      fullNameEn: fullNameEn.trim() != original.fullNameEn.trim()
          ? (fullNameEn.trim().isNotEmpty ? fullNameEn.trim() : null)
          : null,
      email: email?.trim() != original.email?.trim() ? email?.trim() : null,
      nationalId: nationalId.trim() != original.nationalId.trim()
          ? (nationalId.trim().isNotEmpty ? nationalId.trim() : null)
          : null,
      nationalIdExpiry: nationalIdExpiry.trim() != original.nationalIdExpiry.trim()
          ? (nationalIdExpiry.trim().isNotEmpty ? nationalIdExpiry.trim() : null)
          : null,
      dateOfBirth: dateOfBirth?.trim() != original.dateOfBirth?.trim()
          ? (dateOfBirth?.trim().isNotEmpty == true
              ? dateOfBirth!.trim().replaceAll('/', '-')
              : null)
          : null,
      nationality: nationality.trim() != original.nationality.trim()
          ? (nationality.trim().isNotEmpty ? nationality.trim() : null)
          : null,
      vehicleType: vehicleType.trim() != original.vehicleType.trim()
          ? (vehicleType.trim().isNotEmpty ? vehicleType.trim() : null)
          : null,
      vehicleModel: vehicleModel.trim() != original.vehicleModel.trim()
          ? (vehicleModel.trim().isNotEmpty ? vehicleModel.trim() : null)
          : null,
      vehiclePlate: vehiclePlate.trim() != original.vehiclePlate.trim()
          ? (vehiclePlate.trim().isNotEmpty ? vehiclePlate.trim() : null)
          : null,
      vehicleYear: vehicleYear != original.vehicleYear && vehicleYear > 0
          ? vehicleYear
          : null,
      vehicleColor: vehicleColor?.trim() != original.vehicleColor?.trim()
          ? (vehicleColor?.trim().isNotEmpty == true
              ? vehicleColor!.trim()
              : null)
          : null,
      isVehicleOwned: isVehicleOwned != original.isVehicleOwned
          ? isVehicleOwned
          : null,
      licenseNumber: licenseNumber.trim() != original.licenseNumber.trim()
          ? (licenseNumber.trim().isNotEmpty ? licenseNumber.trim() : null)
          : null,
      licenseExpiry: licenseExpiry.trim() != original.licenseExpiry.trim()
          ? (licenseExpiry.trim().isNotEmpty ? licenseExpiry.trim() : null)
          : null,
      vehicleLicenseExpiry: vehicleLicenseExpiry.trim() != original.vehicleLicenseExpiry.trim()
          ? (vehicleLicenseExpiry.trim().isNotEmpty
              ? vehicleLicenseExpiry.trim()
              : null)
          : null,
      contractExpiry: contractExpiry?.trim() != original.contractExpiry?.trim()
          ? (contractExpiry?.trim().isNotEmpty == true
              ? contractExpiry!.trim()
              : null)
          : null,
      nationalIdFrontStorageKey: (newlyUploadedDocumentIds.contains('civil-card') ||
              nationalIdFrontStorageKey != original.nationalIdFrontStorageKey) &&
          nationalIdFrontStorageKey.isNotEmpty
          ? nationalIdFrontStorageKey
          : null,
      nationalIdBackStorageKey: (newlyUploadedDocumentIds.contains('civil-card') ||
              nationalIdBackStorageKey != original.nationalIdBackStorageKey) &&
          nationalIdBackStorageKey.isNotEmpty
          ? nationalIdBackStorageKey
          : null,
      drivingLicenseFrontStorageKey: (newlyUploadedDocumentIds.contains('driving-license') ||
              drivingLicenseFrontStorageKey != original.drivingLicenseFrontStorageKey) &&
          drivingLicenseFrontStorageKey.isNotEmpty
          ? drivingLicenseFrontStorageKey
          : null,
      drivingLicenseBackStorageKey: (newlyUploadedDocumentIds.contains('driving-license') ||
              drivingLicenseBackStorageKey != original.drivingLicenseBackStorageKey) &&
          drivingLicenseBackStorageKey.isNotEmpty
          ? drivingLicenseBackStorageKey
          : null,
      vehicleRegistrationStorageKey: (newlyUploadedDocumentIds.contains('car-registration') ||
              vehicleRegistrationStorageKey != original.vehicleRegistrationStorageKey) &&
          vehicleRegistrationStorageKey.isNotEmpty
          ? vehicleRegistrationStorageKey
          : null,
      profileImageStorageKey: (newlyUploadedDocumentIds.contains('personal-photo') ||
              profileImageStorageKey != original.profileImageStorageKey) &&
          (profileImageStorageKey != null && profileImageStorageKey!.isNotEmpty)
          ? profileImageStorageKey
          : null,
      vehiclePhotoStorageKey: (newlyUploadedDocumentIds.contains('vehicle-photo') ||
              vehiclePhotoStorageKey != original.vehiclePhotoStorageKey) &&
          (vehiclePhotoStorageKey != null && vehiclePhotoStorageKey!.isNotEmpty)
          ? vehiclePhotoStorageKey
          : null,
      contractStorageKey: (newlyUploadedDocumentIds.contains('contract') ||
              contractStorageKey != original.contractStorageKey) &&
          (contractStorageKey != null && contractStorageKey!.isNotEmpty)
          ? contractStorageKey
          : null,
    );
  }

  DriverRegistrationDraftEntity copyWith({
    String? restaurantId,
    String? restaurantName,
    String? fullNameAr,
    String? fullNameEn,
    String? phone,
    String? password,
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
    bool clearContractExpiry = false,
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
      password: password ?? this.password,
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
      vehicleLicenseExpiry: vehicleLicenseExpiry ?? this.vehicleLicenseExpiry,
      contractExpiry: clearContractExpiry
          ? null
          : (contractExpiry ?? this.contractExpiry),
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
