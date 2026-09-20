// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_resubmit_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverResubmitRequestDto _$DriverResubmitRequestDtoFromJson(
  Map<String, dynamic> json,
) => DriverResubmitRequestDto(
  restaurantId: json['restaurantId'] as String?,
  fullNameAr: json['fullNameAr'] as String?,
  fullNameEn: json['fullNameEn'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  nationalId: json['nationalId'] as String?,
  nationalIdExpiry: json['nationalIdExpiry'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
  nationality: json['nationality'] as String?,
  vehicleType: json['vehicleType'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
  vehicleYear: (json['vehicleYear'] as num?)?.toInt(),
  vehicleColor: json['vehicleColor'] as String?,
  isVehicleOwned: json['isVehicleOwned'] as bool?,
  licenseNumber: json['licenseNumber'] as String?,
  licenseExpiry: json['licenseExpiry'] as String?,
  vehicleLicenseExpiry: json['vehicleLicenseExpiry'] as String?,
  contractExpiry: json['contractExpiry'] as String?,
  nationalIdFrontStorageKey: json['nationalIdFrontStorageKey'] as String?,
  nationalIdBackStorageKey: json['nationalIdBackStorageKey'] as String?,
  drivingLicenseFrontStorageKey:
      json['drivingLicenseFrontStorageKey'] as String?,
  drivingLicenseBackStorageKey: json['drivingLicenseBackStorageKey'] as String?,
  vehicleRegistrationStorageKey:
      json['vehicleRegistrationStorageKey'] as String?,
  profileImageStorageKey: json['profileImageStorageKey'] as String?,
  vehiclePhotoStorageKey: json['vehiclePhotoStorageKey'] as String?,
  contractStorageKey: json['contractStorageKey'] as String?,
);

Map<String, dynamic> _$DriverResubmitRequestDtoToJson(
  DriverResubmitRequestDto instance,
) => <String, dynamic>{
  'restaurantId': ?instance.restaurantId,
  'fullNameAr': ?instance.fullNameAr,
  'fullNameEn': ?instance.fullNameEn,
  'phone': ?instance.phone,
  'email': ?instance.email,
  'nationalId': ?instance.nationalId,
  'nationalIdExpiry': ?instance.nationalIdExpiry,
  'dateOfBirth': ?instance.dateOfBirth,
  'nationality': ?instance.nationality,
  'vehicleType': ?instance.vehicleType,
  'vehicleModel': ?instance.vehicleModel,
  'vehiclePlate': ?instance.vehiclePlate,
  'vehicleYear': ?instance.vehicleYear,
  'vehicleColor': ?instance.vehicleColor,
  'isVehicleOwned': ?instance.isVehicleOwned,
  'licenseNumber': ?instance.licenseNumber,
  'licenseExpiry': ?instance.licenseExpiry,
  'vehicleLicenseExpiry': ?instance.vehicleLicenseExpiry,
  'contractExpiry': ?instance.contractExpiry,
  'nationalIdFrontStorageKey': ?instance.nationalIdFrontStorageKey,
  'nationalIdBackStorageKey': ?instance.nationalIdBackStorageKey,
  'drivingLicenseFrontStorageKey': ?instance.drivingLicenseFrontStorageKey,
  'drivingLicenseBackStorageKey': ?instance.drivingLicenseBackStorageKey,
  'vehicleRegistrationStorageKey': ?instance.vehicleRegistrationStorageKey,
  'profileImageStorageKey': ?instance.profileImageStorageKey,
  'vehiclePhotoStorageKey': ?instance.vehiclePhotoStorageKey,
  'contractStorageKey': ?instance.contractStorageKey,
};
