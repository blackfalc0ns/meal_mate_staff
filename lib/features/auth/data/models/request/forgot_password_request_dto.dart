import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_request_dto.g.dart';

@JsonSerializable()
class ForgotPasswordRequestDto {
  const ForgotPasswordRequestDto({required this.phone, required this.role});

  factory ForgotPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestDtoFromJson(json);

  final String phone;
  final String role;

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestDtoToJson(this);
}
