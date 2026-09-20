import 'package:json_annotation/json_annotation.dart';

part 'staff_auth_response_dto.g.dart';

@JsonSerializable()
class StaffAuthResponseDto {
  const StaffAuthResponseDto({
    this.userId,
    this.phoneNumber,
    this.fullName,
    this.userType,
    this.accountStatus,
    this.restaurantId,
    this.roles,
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAtUtc,
    this.isAuthenticated,
  });

  factory StaffAuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$StaffAuthResponseDtoFromJson(json);

  final String? userId;
  final String? phoneNumber;
  final String? fullName;
  final String? userType;
  final String? accountStatus;
  final String? restaurantId;
  final List<String>? roles;
  final String? accessToken;
  final String? refreshToken;
  final String? accessTokenExpiresAtUtc;
  final bool? isAuthenticated;

  Map<String, dynamic> toJson() => _$StaffAuthResponseDtoToJson(this);
}
