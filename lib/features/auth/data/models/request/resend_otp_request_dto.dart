import 'package:json_annotation/json_annotation.dart';

part 'resend_otp_request_dto.g.dart';

@JsonSerializable()
class ResendOtpRequestDto {
  const ResendOtpRequestDto({required this.phone, required this.role});

  factory ResendOtpRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpRequestDtoFromJson(json);

  final String phone;
  final String role;

  Map<String, dynamic> toJson() => _$ResendOtpRequestDtoToJson(this);
}
