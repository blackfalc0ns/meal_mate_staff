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

  factory DeliveryContactCaseResponseDto.fromJson(Map<String, dynamic> json) {
    return DeliveryContactCaseResponseDto(
      contactCaseId: json['contactCaseId'] as String?,
      tripStopId: json['tripStopId'] as String?,
      status: (json['status'] ?? json['state']) as String?,
      attemptCount:
          ((json['attemptCount'] ?? json['qualifiedMissedCount']) as num?)
              ?.toInt(),
      firstAttemptCallId: json['firstAttemptCallId'] as String?,
      lastAttemptCallId:
          (json['lastAttemptCallId'] ?? json['lastCallId']) as String?,
      canHold: json['canHold'] as bool?,
      canResume: (json['canResume'] ?? json['holdResumed']) as bool?,
      canRevealPhone: json['canRevealPhone'] as bool?,
      resumeCooldownRemainingSeconds:
          (json['resumeCooldownRemainingSeconds'] as num?)?.toInt(),
      customerPhoneMasked: json['customerPhoneMasked'] as String?,
    );
  }

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

  Map<String, dynamic> toJson() => _$DeliveryContactCaseResponseDtoToJson(this);
}
