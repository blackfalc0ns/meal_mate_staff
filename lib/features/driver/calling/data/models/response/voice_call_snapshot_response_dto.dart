import 'package:json_annotation/json_annotation.dart';

part 'voice_call_snapshot_response_dto.g.dart';

@JsonSerializable()
class VoiceCallSnapshotResponseDto {
  const VoiceCallSnapshotResponseDto({
    this.callId,
    this.tripStopId,
    this.status,
    this.protocolVersion,
    this.sequence,
    this.endReason,
    this.startedAtUtc,
    this.acceptedAtUtc,
    this.connectedAtUtc,
    this.endedAtUtc,
    this.durationSeconds,
    this.deadlineAtUtc,
    this.winningDeviceSessionId,
    this.localParticipantRole,
  });

  factory VoiceCallSnapshotResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallSnapshotResponseDtoFromJson(json);

  final String? callId;
  final String? tripStopId;
  final String? status;
  final int? protocolVersion;
  final int? sequence;
  final String? endReason;
  final String? startedAtUtc;
  final String? acceptedAtUtc;
  final String? connectedAtUtc;
  final String? endedAtUtc;
  final int? durationSeconds;
  final String? deadlineAtUtc;
  final String? winningDeviceSessionId;
  final String? localParticipantRole;

  Map<String, dynamic> toJson() => _$VoiceCallSnapshotResponseDtoToJson(this);
}
