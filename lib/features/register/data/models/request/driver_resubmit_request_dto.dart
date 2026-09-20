import 'package:json_annotation/json_annotation.dart';

part 'driver_resubmit_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverResubmitRequestDto {
  const DriverResubmitRequestDto({
    this.restaurantId,
    this.fullNameAr,
    this.fullNameEn,
    this.phone,
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

  factory DriverResubmitRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverResubmitRequestDtoFromJson(json);

  final String? restaurantId;
  final String? fullNameAr;
  final String? fullNameEn;
  final String? phone;
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

  Map<String, dynamic> toJson() => _$DriverResubmitRequestDtoToJson(this);
}
