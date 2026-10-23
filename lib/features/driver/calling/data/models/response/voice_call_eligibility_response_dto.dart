import 'package:json_annotation/json_annotation.dart';

part 'voice_call_eligibility_response_dto.g.dart';

@JsonSerializable()
class VoiceCallEligibilityResponseDto {
  const VoiceCallEligibilityResponseDto({
    this.canInitiate,
    this.reasonCode,
    this.distanceMeters,
    this.locationAgeSeconds,
    this.canHold,
    this.canRetry,
    this.canRevealPhone,
    this.contactCaseId,
  });

  factory VoiceCallEligibilityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallEligibilityResponseDtoFromJson(json);

  final bool? canInitiate;
  final String? reasonCode;
  final double? distanceMeters;
  final int? locationAgeSeconds;
  final bool? canHold;
  final bool? canRetry;
  final bool? canRevealPhone;
  final String? contactCaseId;

  Map<String, dynamic> toJson() =>
      _$VoiceCallEligibilityResponseDtoToJson(this);
}
