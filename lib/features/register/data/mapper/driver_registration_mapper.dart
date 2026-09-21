import '../../domain/entities/driver_file_upload_result_entity.dart';
import '../../domain/entities/driver_registration_draft_entity.dart';
import '../../domain/entities/driver_registration_result_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../../domain/entities/driver_resubmit_entity.dart';
import '../../domain/entities/driver_vehicle_color_entity.dart';
import '../../domain/entities/driver_vehicle_model_entity.dart';
import '../../domain/entities/driver_vehicle_type_entity.dart';
import '../models/request/driver_registration_request_dto.dart';
import '../models/request/driver_resubmit_request_dto.dart';
import '../models/response/driver_file_upload_response_dto.dart';
import '../models/response/driver_registration_response_dto.dart';
import '../models/response/driver_restaurant_response_dto.dart';
import '../models/response/driver_nationality_response_dto.dart';
import '../models/response/driver_vehicle_color_response_dto.dart';
import '../models/response/driver_vehicle_model_response_dto.dart';
import '../models/response/driver_vehicle_type_response_dto.dart';

String _normalizeVehicleColorHex(String? value) {
  final rawValue = value?.trim();
  if (rawValue == null || rawValue.isEmpty) {
    return '';
  }

  final hex = rawValue.startsWith('#') ? rawValue.substring(1) : rawValue;
  if ((hex.length != 6 && hex.length != 8) ||
      !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
    return '';
  }

  final rgb = hex.length == 8 ? hex.substring(2) : hex;
  return '#${rgb.toUpperCase()}';
}

extension DriverVehicleTypeResponseDtoMapper on DriverVehicleTypeResponseDto {
  DriverVehicleTypeEntity toEntity() {
    final fallbackName = nameEn ?? nameAr ?? '';
    return DriverVehicleTypeEntity(
      code: code ?? '',
      nameAr: nameAr ?? fallbackName,
      nameEn: nameEn ?? fallbackName,
      iconKey: iconKey ?? '',
    );
  }
}

extension DriverVehicleColorResponseDtoMapper on DriverVehicleColorResponseDto {
  DriverVehicleColorEntity toEntity() {
    final fallbackName = nameEn ?? nameAr ?? '';
    return DriverVehicleColorEntity(
      hex: _normalizeVehicleColorHex(hex),
      nameAr: nameAr ?? fallbackName,
      nameEn: nameEn ?? fallbackName,
      isDefault: isDefault ?? false,
      displayOrder: displayOrder ?? 0,
    );
  }
}

extension DriverVehicleModelResponseDtoMapper on DriverVehicleModelResponseDto {
  DriverVehicleModelEntity toEntity() {
    final fallbackMakeName = makeNameEn ?? makeNameAr ?? '';
    final fallbackModelName = modelNameEn ?? modelNameAr ?? '';
    final fallbackFullName = '$fallbackMakeName $fallbackModelName'.trim();
    return DriverVehicleModelEntity(
      value: value ?? '',
      makeCode: makeCode ?? '',
      makeNameAr: makeNameAr ?? fallbackMakeName,
      makeNameEn: makeNameEn ?? fallbackMakeName,
      modelCode: modelCode ?? '',
      modelNameAr: modelNameAr ?? fallbackModelName,
      modelNameEn: modelNameEn ?? fallbackModelName,
      fullNameAr: fullNameAr ?? fullNameEn ?? fallbackFullName,
      fullNameEn: fullNameEn ?? fullNameAr ?? fallbackFullName,
      vehicleType: vehicleType ?? '',
    );
  }
}

extension DriverNationalityResponseDtoMapper on DriverNationalityResponseDto {
  DriverNationalityEntity toEntity() {
    final fallbackName = name ?? '';
    final fallbackCountry = countryName ?? '';
    return DriverNationalityEntity(
      code: code ?? '',
      name: fallbackName,
      nameAr: nameAr ?? fallbackName,
      nameEn: nameEn ?? fallbackName,
      countryName: fallbackCountry,
      countryNameAr: countryNameAr ?? fallbackCountry,
      countryNameEn: countryNameEn ?? fallbackCountry,
      flagEmoji: flagEmoji ?? '',
    );
  }
}

extension DriverRestaurantResponseDtoMapper on DriverRestaurantResponseDto {
  DriverRestaurantEntity toEntity() {
    final fallbackName = tradeName ?? '';
    return DriverRestaurantEntity(
      id: id ?? '',
      tradeName: fallbackName,
      tradeNameAr: tradeNameAr ?? fallbackName,
      tradeNameEn: tradeNameEn ?? fallbackName,
      logoUrl: logoUrl,
      contactPhone: contactPhone,
    );
  }
}

extension DriverFileUploadResponseDtoMapper on DriverFileUploadResponseDto {
  DriverFileUploadResultEntity toEntity() {
    return DriverFileUploadResultEntity(
      storageKey: storageKey ?? '',
      readUrl: readUrl,
      fileName: fileName,
      contentType: contentType,
      sizeBytes: sizeBytes,
    );
  }
}

extension DriverRegistrationResponseDtoMapper on DriverRegistrationResponseDto {
  DriverRegistrationResultEntity toEntity() {
    return DriverRegistrationResultEntity(
      registrationId: registrationId ?? '',
      restaurantId: restaurantId ?? '',
      restaurantName: restaurantName ?? '',
      phone: phone ?? '',
      status: status ?? 'Submitted',
      message: message ?? '',
    );
  }
}

extension DriverRegistrationDraftEntityMapper on DriverRegistrationDraftEntity {
  DriverRegistrationRequestDto toDto() {
    return DriverRegistrationRequestDto(
      restaurantId: restaurantId,
      fullNameAr: fullNameAr,
      fullNameEn: fullNameEn,
      phone: phone,
      email: (email != null && email!.trim().isNotEmpty) ? email!.trim() : null,
      nationalId: nationalId,
      nationalIdExpiry: nationalIdExpiry,
      dateOfBirth: (dateOfBirth != null && dateOfBirth!.trim().isNotEmpty)
          ? dateOfBirth!.trim().replaceAll('/', '-')
          : null,
      nationality: nationality,
      vehicleType: vehicleType,
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
      vehicleYear: vehicleYear,
      vehicleColor: (vehicleColor != null && vehicleColor!.trim().isNotEmpty)
          ? vehicleColor!.trim()
          : null,
      isVehicleOwned: isVehicleOwned,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      vehicleLicenseExpiry: vehicleLicenseExpiry,
      contractExpiry:
          (contractExpiry != null && contractExpiry!.trim().isNotEmpty)
          ? contractExpiry!.trim()
          : null,
      nationalIdFrontStorageKey: nationalIdFrontStorageKey,
      nationalIdBackStorageKey: nationalIdBackStorageKey,
      drivingLicenseFrontStorageKey: drivingLicenseFrontStorageKey,
      drivingLicenseBackStorageKey: drivingLicenseBackStorageKey,
      vehicleRegistrationStorageKey: vehicleRegistrationStorageKey,
      profileImageStorageKey:
          (profileImageStorageKey != null &&
              profileImageStorageKey!.trim().isNotEmpty)
          ? profileImageStorageKey!.trim()
          : null,
      vehiclePhotoStorageKey:
          (vehiclePhotoStorageKey != null &&
              vehiclePhotoStorageKey!.trim().isNotEmpty)
          ? vehiclePhotoStorageKey!.trim()
          : null,
      contractStorageKey:
          (contractStorageKey != null && contractStorageKey!.trim().isNotEmpty)
          ? contractStorageKey!.trim()
          : null,
    );
  }
}

extension DriverResubmitEntityMapper on DriverResubmitEntity {
  DriverResubmitRequestDto toDto() {
    return DriverResubmitRequestDto(
      restaurantId: restaurantId,
      fullNameAr: fullNameAr,
      fullNameEn: fullNameEn,
      phone: phone,
      email: email,
      nationalId: nationalId,
      nationalIdExpiry: nationalIdExpiry,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      vehicleType: vehicleType,
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
      vehicleYear: vehicleYear,
      vehicleColor: vehicleColor,
      isVehicleOwned: isVehicleOwned,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      vehicleLicenseExpiry: vehicleLicenseExpiry,
      contractExpiry: contractExpiry,
      nationalIdFrontStorageKey: nationalIdFrontStorageKey,
      nationalIdBackStorageKey: nationalIdBackStorageKey,
      drivingLicenseFrontStorageKey: drivingLicenseFrontStorageKey,
      drivingLicenseBackStorageKey: drivingLicenseBackStorageKey,
      vehicleRegistrationStorageKey: vehicleRegistrationStorageKey,
      profileImageStorageKey: profileImageStorageKey,
      vehiclePhotoStorageKey: vehiclePhotoStorageKey,
      contractStorageKey: contractStorageKey,
    );
  }
}
