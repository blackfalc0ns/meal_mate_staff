import 'package:json_annotation/json_annotation.dart';

part 'verify_first_time_otp_request_dto.g.dart';

@JsonSerializable()
class VerifyFirstTimeOtpRequestDto {
  const VerifyFirstTimeOtpRequestDto({
    required this.phone,
    required this.role,
    required this.otpCode,
  });

  factory VerifyFirstTimeOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyFirstTimeOtpRequestDtoFromJson(json);

  final String phone;
  final String role;
  final String otpCode;

  Map<String, dynamic> toJson() => _$VerifyFirstTimeOtpRequestDtoToJson(this);
}
