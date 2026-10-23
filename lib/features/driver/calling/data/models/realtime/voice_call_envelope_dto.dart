class VoiceCallEnvelopeDto {
  const VoiceCallEnvelopeDto({
    required this.eventId,
    required this.protocolVersion,
    required this.callId,
    required this.sequence,
    required this.eventType,
    required this.occurredAtUtc,
    this.sentAtUtc,
    this.expiresAtUtc,
    this.payload,
  });

  final String eventId;
  final int protocolVersion;
  final String callId;
  final int sequence;
  final String eventType;
  final String occurredAtUtc;
  final String? sentAtUtc;
  final String? expiresAtUtc;
  final Map<String, dynamic>? payload;

  factory VoiceCallEnvelopeDto.fromJson(Map<String, dynamic> json) {
    return VoiceCallEnvelopeDto(
      eventId: json['eventId']?.toString() ?? '',
      protocolVersion: (json['protocolVersion'] as num?)?.toInt() ?? 2,
      callId: json['callId']?.toString() ?? '',
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      eventType: json['eventType']?.toString() ?? '',
      occurredAtUtc: json['occurredAtUtc']?.toString() ?? '',
      sentAtUtc: json['sentAtUtc']?.toString(),
      expiresAtUtc: json['expiresAtUtc']?.toString(),
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'protocolVersion': protocolVersion,
        'callId': callId,
        'sequence': sequence,
        'eventType': eventType,
        'occurredAtUtc': occurredAtUtc,
        if (sentAtUtc != null) 'sentAtUtc': sentAtUtc,
        if (expiresAtUtc != null) 'expiresAtUtc': expiresAtUtc,
        if (payload != null) 'payload': payload,
      };
}
