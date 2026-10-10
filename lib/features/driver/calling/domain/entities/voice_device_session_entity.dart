class VoiceDeviceSessionEntity {
  const VoiceDeviceSessionEntity({
    required this.deviceSessionId,
    required this.controlProof,
    required this.expiresAtUtc,
  });

  final String deviceSessionId;
  final String controlProof;
  final DateTime expiresAtUtc;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAtUtc);
}
