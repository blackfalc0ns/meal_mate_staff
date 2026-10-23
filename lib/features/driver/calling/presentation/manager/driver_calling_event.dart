import '../../domain/entities/voice_call_snapshot_entity.dart';
import '../../domain/entities/voice_call_status.dart';

sealed class DriverCallingEvent {
  const DriverCallingEvent();
}

class CheckEligibilityEvent extends DriverCallingEvent {
  const CheckEligibilityEvent(this.tripStopId);
  final String tripStopId;
}

class InitiateCallEvent extends DriverCallingEvent {
  const InitiateCallEvent({
    required this.tripStopId,
    this.customerName,
    this.addressLine,
    this.area,
  });

  final String tripStopId;
  final String? customerName;
  final String? addressLine;
  final String? area;
}

class CancelCallEvent extends DriverCallingEvent {
  const CancelCallEvent([this.callId]);
  final String? callId;
}

class EndCallEvent extends DriverCallingEvent {
  const EndCallEvent([this.callId]);
  final String? callId;
}

class ToggleMuteEvent extends DriverCallingEvent {
  const ToggleMuteEvent();
}

class ToggleSpeakerEvent extends DriverCallingEvent {
  const ToggleSpeakerEvent();
}

class HoldCallEvent extends DriverCallingEvent {
  const HoldCallEvent({required this.notes});
  final String notes;
}

class ResumeCallEvent extends DriverCallingEvent {
  const ResumeCallEvent();
}

class RevealPhoneEvent extends DriverCallingEvent {
  const RevealPhoneEvent({required this.reason});
  final String reason;
}

class FetchCallDisplayEvent extends DriverCallingEvent {
  const FetchCallDisplayEvent(this.callId, {this.languageCode});
  final String callId;
  final String? languageCode;
}

class ClearFeedbackEvent extends DriverCallingEvent {
  const ClearFeedbackEvent();
}

class SnapshotUpdatedEvent extends DriverCallingEvent {
  const SnapshotUpdatedEvent(this.snapshot);
  final VoiceCallSnapshotEntity snapshot;
}

class StatusChangedEvent extends DriverCallingEvent {
  const StatusChangedEvent(this.status);
  final VoiceCallStatus status;
}

class TickCallDurationEvent extends DriverCallingEvent {
  const TickCallDurationEvent();
}
