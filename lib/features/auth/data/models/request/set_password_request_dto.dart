import 'package:json_annotation/json_annotation.dart';

part 'set_password_request_dto.g.dart';

@JsonSerializable()
class SetPasswordRequestDto {
  const SetPasswordRequestDto({
    required this.phone,
    required this.role,
    required this.verificationToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory SetPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordRequestDtoFromJson(json);

  final String phone;
  final String role;
  final String verificationToken;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => _$SetPasswordRequestDtoToJson(this);
}
