import 'package:json_annotation/json_annotation.dart';

part 'driver_registration_request_dto.g.dart';

@JsonSerializable()
class DriverRegistrationRequestDto {
  const DriverRegistrationRequestDto({
    required this.restaurantId,
    required this.fullNameAr,
    required this.fullNameEn,
    required this.phone,
    required this.password,
    this.email,
    required this.nationalId,
    required this.nationalIdExpiry,
    this.dateOfBirth,
    required this.nationality,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleYear,
    this.vehicleColor,
    required this.isVehicleOwned,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.vehicleLicenseExpiry,
    this.contractExpiry,
    required this.nationalIdFrontStorageKey,
    required this.nationalIdBackStorageKey,
    required this.drivingLicenseFrontStorageKey,
    required this.drivingLicenseBackStorageKey,
    required this.vehicleRegistrationStorageKey,
    this.profileImageStorageKey,
    this.vehiclePhotoStorageKey,
    this.contractStorageKey,
  });

  factory DriverRegistrationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverRegistrationRequestDtoFromJson(json);

  final String restaurantId;
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

  Map<String, dynamic> toJson() => _$DriverRegistrationRequestDtoToJson(this);
}
