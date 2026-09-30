import 'package:json_annotation/json_annotation.dart';

part 'driver_reset_password_request_dto.g.dart';

@JsonSerializable()
class DriverResetPasswordRequestDto {
  const DriverResetPasswordRequestDto({
    required this.phone,
    required this.otpCode,
    required this.newPassword,
  });

  factory DriverResetPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverResetPasswordRequestDtoFromJson(json);

  final String phone;
  final String otpCode;
  final String newPassword;

  Map<String, dynamic> toJson() => _$DriverResetPasswordRequestDtoToJson(this);
}
