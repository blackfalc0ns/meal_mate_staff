import 'package:json_annotation/json_annotation.dart';

part 'delivery_contact_case_response_dto.g.dart';

@JsonSerializable()
class DeliveryContactCaseResponseDto {
  const DeliveryContactCaseResponseDto({
    this.contactCaseId,
    this.tripStopId,
    this.status,
    this.attemptCount,
    this.firstAttemptCallId,
    this.lastAttemptCallId,
    this.canHold,
    this.canResume,
    this.canRevealPhone,
    this.resumeCooldownRemainingSeconds,
    this.customerPhoneMasked,
  });

  factory DeliveryContactCaseResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryContactCaseResponseDtoFromJson(json);

  final String? contactCaseId;
  final String? tripStopId;
  final String? status;
  final int? attemptCount;
  final String? firstAttemptCallId;
  final String? lastAttemptCallId;
  final bool? canHold;
  final bool? canResume;
  final bool? canRevealPhone;
  final int? resumeCooldownRemainingSeconds;
  final String? customerPhoneMasked;

  Map<String, dynamic> toJson() =>
      _$DeliveryContactCaseResponseDtoToJson(this);
}
