import 'package:json_annotation/json_annotation.dart';

part 'driver_auth_response_dto.g.dart';

@JsonSerializable()
class DriverAuthResponseDto {
  const DriverAuthResponseDto({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.userId,
    this.phoneNumber,
    this.fullName,
    this.userType,
    this.accountStatus,
    this.restaurantId,
    this.roles,
    this.permissions,
    this.nextStep,
  });

  factory DriverAuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverAuthResponseDtoFromJson(json);

  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String? userId;
  final String? phoneNumber;
  final String? fullName;
  final String? userType;
  final String? accountStatus;
  final String? restaurantId;
  final List<String>? roles;
  final List<String>? permissions;
  final String? nextStep;

  Map<String, dynamic> toJson() => _$DriverAuthResponseDtoToJson(this);
}
