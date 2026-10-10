class VoiceCallEligibilityEntity {
  const VoiceCallEligibilityEntity({
    required this.canInitiate,
    required this.reasonCode,
    this.distanceMeters,
    this.locationAgeSeconds,
    this.canHold = false,
    this.canRetry = false,
    this.canRevealPhone = false,
    this.contactCaseId,
  });

  final bool canInitiate;
  final String reasonCode;
  final double? distanceMeters;
  final int? locationAgeSeconds;
  final bool canHold;
  final bool canRetry;
  final bool canRevealPhone;
  final String? contactCaseId;

  VoiceCallEligibilityEntity copyWith({
    bool? canInitiate,
    String? reasonCode,
    double? distanceMeters,
    int? locationAgeSeconds,
    bool? canHold,
    bool? canRetry,
    bool? canRevealPhone,
    String? contactCaseId,
  }) {
    return VoiceCallEligibilityEntity(
      canInitiate: canInitiate ?? this.canInitiate,
      reasonCode: reasonCode ?? this.reasonCode,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      locationAgeSeconds: locationAgeSeconds ?? this.locationAgeSeconds,
      canHold: canHold ?? this.canHold,
      canRetry: canRetry ?? this.canRetry,
      canRevealPhone: canRevealPhone ?? this.canRevealPhone,
      contactCaseId: contactCaseId ?? this.contactCaseId,
    );
  }
}
