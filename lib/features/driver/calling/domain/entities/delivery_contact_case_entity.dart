class DeliveryContactCaseEntity {
  const DeliveryContactCaseEntity({
    required this.contactCaseId,
    required this.tripStopId,
    required this.status,
    this.attemptCount = 0,
    this.firstAttemptCallId,
    this.lastAttemptCallId,
    this.canHold = false,
    this.canResume = false,
    this.canRevealPhone = false,
    this.resumeCooldownRemainingSeconds = 0,
    this.customerPhoneMasked,
  });

  final String contactCaseId;
  final String tripStopId;
  final String status;
  final int attemptCount;
  final String? firstAttemptCallId;
  final String? lastAttemptCallId;
  final bool canHold;
  final bool canResume;
  final bool canRevealPhone;
  final int resumeCooldownRemainingSeconds;
  final String? customerPhoneMasked;

  bool get isOnHold => status.toLowerCase() == 'onhold' || status.toLowerCase() == 'hold';

  DeliveryContactCaseEntity copyWith({
    String? contactCaseId,
    String? tripStopId,
    String? status,
    int? attemptCount,
    String? firstAttemptCallId,
    String? lastAttemptCallId,
    bool? canHold,
    bool? canResume,
    bool? canRevealPhone,
    int? resumeCooldownRemainingSeconds,
    String? customerPhoneMasked,
  }) {
    return DeliveryContactCaseEntity(
      contactCaseId: contactCaseId ?? this.contactCaseId,
      tripStopId: tripStopId ?? this.tripStopId,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      firstAttemptCallId: firstAttemptCallId ?? this.firstAttemptCallId,
      lastAttemptCallId: lastAttemptCallId ?? this.lastAttemptCallId,
      canHold: canHold ?? this.canHold,
      canResume: canResume ?? this.canResume,
      canRevealPhone: canRevealPhone ?? this.canRevealPhone,
      resumeCooldownRemainingSeconds:
          resumeCooldownRemainingSeconds ?? this.resumeCooldownRemainingSeconds,
      customerPhoneMasked: customerPhoneMasked ?? this.customerPhoneMasked,
    );
  }
}
