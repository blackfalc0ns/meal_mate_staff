enum VoiceCallStatus {
  created,
  ringing,
  accepted,
  connecting,
  active,
  rejected,
  cancelled,
  missed,
  failed,
  ended;

  bool get isTerminal => switch (this) {
        rejected || cancelled || missed || failed || ended => true,
        _ => false,
      };

  bool get isConnectingOrActive => switch (this) {
        connecting || active => true,
        _ => false,
      };

  bool get isAudioActive => this == active;

  static VoiceCallStatus fromString(String? raw) {
    if (raw == null) return VoiceCallStatus.created;
    return switch (raw.toLowerCase().trim()) {
      'created' => VoiceCallStatus.created,
      'ringing' => VoiceCallStatus.ringing,
      'accepted' => VoiceCallStatus.accepted,
      'connecting' => VoiceCallStatus.connecting,
      'active' => VoiceCallStatus.active,
      'rejected' => VoiceCallStatus.rejected,
      'cancelled' || 'canceled' => VoiceCallStatus.cancelled,
      'missed' => VoiceCallStatus.missed,
      'failed' => VoiceCallStatus.failed,
      'ended' => VoiceCallStatus.ended,
      _ => VoiceCallStatus.created,
    };
  }

  String toWire() => switch (this) {
        created => 'Created',
        ringing => 'Ringing',
        accepted => 'Accepted',
        connecting => 'Connecting',
        active => 'Active',
        rejected => 'Rejected',
        cancelled => 'Cancelled',
        missed => 'Missed',
        failed => 'Failed',
        ended => 'Ended',
      };
}
