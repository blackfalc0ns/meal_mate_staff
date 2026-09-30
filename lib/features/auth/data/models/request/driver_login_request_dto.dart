import 'package:json_annotation/json_annotation.dart';

part 'driver_login_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverLoginRequestDto {
  const DriverLoginRequestDto({
    required this.phone,
    required this.password,
    this.email,
  });

  factory DriverLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverLoginRequestDtoFromJson(json);

  final String phone;
  final String password;
  final String? email;

  Map<String, dynamic> toJson() => _$DriverLoginRequestDtoToJson(this);
}
