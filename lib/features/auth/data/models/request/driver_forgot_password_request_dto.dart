import 'package:json_annotation/json_annotation.dart';

part 'driver_forgot_password_request_dto.g.dart';

@JsonSerializable()
class DriverForgotPasswordRequestDto {
  const DriverForgotPasswordRequestDto({required this.phone});

  factory DriverForgotPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverForgotPasswordRequestDtoFromJson(json);

  final String phone;

  Map<String, dynamic> toJson() => _$DriverForgotPasswordRequestDtoToJson(this);
}
