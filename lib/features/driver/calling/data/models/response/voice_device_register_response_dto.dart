class VoiceDeviceRegisterResponseDto {
  const VoiceDeviceRegisterResponseDto({
    required this.deviceSessionId,
    required this.controlProof,
    required this.expiresAtUtc,
  });

  final String deviceSessionId;
  final String controlProof;
  final String expiresAtUtc;

  factory VoiceDeviceRegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return VoiceDeviceRegisterResponseDto(
      deviceSessionId: json['deviceSessionId']?.toString() ?? '',
      controlProof: json['controlProof']?.toString() ?? '',
      expiresAtUtc: json['expiresAtUtc']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceSessionId': deviceSessionId,
    'controlProof': controlProof,
    'expiresAtUtc': expiresAtUtc,
  };
}
