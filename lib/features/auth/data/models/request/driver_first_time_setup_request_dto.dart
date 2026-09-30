import 'package:json_annotation/json_annotation.dart';

part 'driver_first_time_setup_request_dto.g.dart';

@JsonSerializable()
class DriverFirstTimeSetupRequestDto {
  const DriverFirstTimeSetupRequestDto({
    required this.phone,
    required this.otpCode,
    required this.password,
  });

  factory DriverFirstTimeSetupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverFirstTimeSetupRequestDtoFromJson(json);

  final String phone;
  final String otpCode;
  final String password;

  Map<String, dynamic> toJson() => _$DriverFirstTimeSetupRequestDtoToJson(this);
}
