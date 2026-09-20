import 'package:json_annotation/json_annotation.dart';

part 'verify_first_time_otp_response_dto.g.dart';

@JsonSerializable()
class VerifyFirstTimeOtpResponseDto {
  const VerifyFirstTimeOtpResponseDto({
    this.verified,
    this.verificationToken,
    this.phone,
    this.role,
    this.message,
  });

  factory VerifyFirstTimeOtpResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyFirstTimeOtpResponseDtoFromJson(json);

  final bool? verified;
  final String? verificationToken;
  final String? phone;
  final String? role;
  final String? message;

  Map<String, dynamic> toJson() => _$VerifyFirstTimeOtpResponseDtoToJson(this);
}
