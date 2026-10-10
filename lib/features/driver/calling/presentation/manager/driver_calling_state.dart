import '../../domain/entities/delivery_contact_case_entity.dart';
import '../../domain/entities/driver_active_call_entity.dart';
import '../../domain/entities/phone_grant_entity.dart';
import '../../domain/entities/voice_call_display_entity.dart';
import '../../domain/entities/voice_call_eligibility_entity.dart';
import '../../domain/entities/voice_call_snapshot_entity.dart';
import '../../domain/entities/voice_call_status.dart';

class DriverCallingState {
  const DriverCallingState({
    this.status = VoiceCallStatus.created,
    this.snapshot,
    this.eligibility,
    this.contactCase,
    this.phoneGrant,
    this.displayData,
    this.activeCallData,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isInitiating = false,
    this.isCheckingEligibility = false,
    this.isHolding = false,
    this.isResuming = false,
    this.isRevealingPhone = false,
    this.isLoadingDisplay = false,
    this.errorMessage,
    this.lastClientRequestId,
    this.durationSeconds = 0,
  });

  final VoiceCallStatus status;
  final VoiceCallSnapshotEntity? snapshot;
  final VoiceCallEligibilityEntity? eligibility;
  final DeliveryContactCaseEntity? contactCase;
  final PhoneGrantEntity? phoneGrant;
  final VoiceCallDisplayEntity? displayData;
  final DriverActiveCallEntity? activeCallData;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isInitiating;
  final bool isCheckingEligibility;
  final bool isHolding;
  final bool isResuming;
  final bool isRevealingPhone;
  final bool isLoadingDisplay;
  final String? errorMessage;
  final String? lastClientRequestId;
  final int durationSeconds;

  bool get isTerminal => status.isTerminal;
  bool get canInitiate => eligibility?.canInitiate ?? false;

  DriverCallingState copyWith({
    VoiceCallStatus? status,
    VoiceCallSnapshotEntity? snapshot,
    VoiceCallEligibilityEntity? eligibility,
    DeliveryContactCaseEntity? contactCase,
    PhoneGrantEntity? phoneGrant,
    VoiceCallDisplayEntity? displayData,
    DriverActiveCallEntity? activeCallData,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isInitiating,
    bool? isCheckingEligibility,
    bool? isHolding,
    bool? isResuming,
    bool? isRevealingPhone,
    bool? isLoadingDisplay,
    String? errorMessage,
    String? lastClientRequestId,
    int? durationSeconds,
    bool clearError = false,
  }) {
    return DriverCallingState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      eligibility: eligibility ?? this.eligibility,
      contactCase: contactCase ?? this.contactCase,
      phoneGrant: phoneGrant ?? this.phoneGrant,
      displayData: displayData ?? this.displayData,
      activeCallData: activeCallData ?? this.activeCallData,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isInitiating: isInitiating ?? this.isInitiating,
      isCheckingEligibility:
          isCheckingEligibility ?? this.isCheckingEligibility,
      isHolding: isHolding ?? this.isHolding,
      isResuming: isResuming ?? this.isResuming,
      isRevealingPhone: isRevealingPhone ?? this.isRevealingPhone,
      isLoadingDisplay: isLoadingDisplay ?? this.isLoadingDisplay,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastClientRequestId: lastClientRequestId ?? this.lastClientRequestId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
