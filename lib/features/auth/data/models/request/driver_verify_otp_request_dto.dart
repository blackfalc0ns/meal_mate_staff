import 'package:json_annotation/json_annotation.dart';

part 'driver_verify_otp_request_dto.g.dart';

@JsonSerializable()
class DriverVerifyOtpRequestDto {
  const DriverVerifyOtpRequestDto({
    required this.destination,
    this.purpose = 'VerifyPhone',
    required this.code,
  });

  factory DriverVerifyOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverVerifyOtpRequestDtoFromJson(json);

  final String destination;
  final String purpose;
  final String code;

  Map<String, dynamic> toJson() => _$DriverVerifyOtpRequestDtoToJson(this);
}
