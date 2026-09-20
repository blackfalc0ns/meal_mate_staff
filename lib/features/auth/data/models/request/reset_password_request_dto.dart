import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request_dto.g.dart';

@JsonSerializable()
class ResetPasswordRequestDto {
  const ResetPasswordRequestDto({
    required this.phone,
    required this.role,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestDtoFromJson(json);

  final String phone;
  final String role;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => _$ResetPasswordRequestDtoToJson(this);
}
