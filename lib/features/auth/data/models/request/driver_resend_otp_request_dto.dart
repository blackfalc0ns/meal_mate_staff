import 'package:json_annotation/json_annotation.dart';

part 'driver_resend_otp_request_dto.g.dart';

@JsonSerializable()
class DriverResendOtpRequestDto {
  const DriverResendOtpRequestDto({
    required this.destination,
    this.channel = 'Phone',
    this.purpose = 'VerifyPhone',
  });

  factory DriverResendOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverResendOtpRequestDtoFromJson(json);

  final String destination;
  final String channel;
  final String purpose;

  Map<String, dynamic> toJson() => _$DriverResendOtpRequestDtoToJson(this);
}
