import '../../domain/entities/driver_file_upload_result_entity.dart';
import '../../domain/entities/driver_registration_draft_entity.dart';
import '../../domain/entities/driver_registration_result_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/entities/driver_resubmit_entity.dart';
import '../models/request/driver_registration_request_dto.dart';
import '../models/request/driver_resubmit_request_dto.dart';
import '../models/response/driver_file_upload_response_dto.dart';
import '../models/response/driver_registration_response_dto.dart';
import '../models/response/driver_restaurant_response_dto.dart';

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
          ? dateOfBirth!.trim()
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
