import 'package:json_annotation/json_annotation.dart';

part 'driver_registration_response_dto.g.dart';

@JsonSerializable()
class DriverRegistrationResponseDto {
  const DriverRegistrationResponseDto({
    this.registrationId,
    this.restaurantId,
    this.restaurantName,
    this.fullName,
    this.fullNameAr,
    this.fullNameEn,
    this.phone,
    this.email,
    this.status,
    this.message,
  });

  factory DriverRegistrationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverRegistrationResponseDtoFromJson(json);

  final String? registrationId;
  final String? restaurantId;
  final String? restaurantName;
  final String? fullName;
  final String? fullNameAr;
  final String? fullNameEn;
  final String? phone;
  final String? email;
  final String? status;
  final String? message;

  Map<String, dynamic> toJson() => _$DriverRegistrationResponseDtoToJson(this);
}
