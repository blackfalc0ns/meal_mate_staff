import 'voice_call_status.dart';

class VoiceCallSnapshotEntity {
  const VoiceCallSnapshotEntity({
    required this.callId,
    required this.tripStopId,
    required this.protocolVersion,
    required this.sequence,
    required this.status,
    this.endReason,
    this.startedAtUtc,
    this.acceptedAtUtc,
    this.connectedAtUtc,
    this.endedAtUtc,
    this.durationSeconds,
    this.deadlineAtUtc,
    this.winningDeviceSessionId,
    this.localParticipantRole = 'Driver',
  });

  final String callId;
  final String tripStopId;
  final int protocolVersion;
  final int sequence;
  final VoiceCallStatus status;
  final String? endReason;
  final DateTime? startedAtUtc;
  final DateTime? acceptedAtUtc;
  final DateTime? connectedAtUtc;
  final DateTime? endedAtUtc;
  final int? durationSeconds;
  final DateTime? deadlineAtUtc;
  final String? winningDeviceSessionId;
  final String localParticipantRole;

  bool get isTerminal => status.isTerminal;

  VoiceCallSnapshotEntity copyWith({
    String? callId,
    String? tripStopId,
    int? protocolVersion,
    int? sequence,
    VoiceCallStatus? status,
    String? endReason,
    DateTime? startedAtUtc,
    DateTime? acceptedAtUtc,
    DateTime? connectedAtUtc,
    DateTime? endedAtUtc,
    int? durationSeconds,
    DateTime? deadlineAtUtc,
    String? winningDeviceSessionId,
    String? localParticipantRole,
  }) {
    return VoiceCallSnapshotEntity(
      callId: callId ?? this.callId,
      tripStopId: tripStopId ?? this.tripStopId,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      sequence: sequence ?? this.sequence,
      status: status ?? this.status,
      endReason: endReason ?? this.endReason,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      acceptedAtUtc: acceptedAtUtc ?? this.acceptedAtUtc,
      connectedAtUtc: connectedAtUtc ?? this.connectedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      deadlineAtUtc: deadlineAtUtc ?? this.deadlineAtUtc,
      winningDeviceSessionId:
          winningDeviceSessionId ?? this.winningDeviceSessionId,
      localParticipantRole:
          localParticipantRole ?? this.localParticipantRole,
    );
  }
}
