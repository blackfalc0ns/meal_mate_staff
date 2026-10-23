class VoiceCallRtcOfferAnswerDto {
  const VoiceCallRtcOfferAnswerDto({
    required this.type,
    required this.sdp,
    this.callId,
    this.messageId,
    this.generation = 0,
  });

  final String type;
  final String sdp;
  final String? callId;
  final String? messageId;
  final int generation;

  factory VoiceCallRtcOfferAnswerDto.fromJson(
    Map<String, dynamic> json, {
    String? callId,
    String? messageId,
    int generation = 0,
  }) {
    final gen = (json['negotiationGeneration'] ?? json['generation']) as num?;
    return VoiceCallRtcOfferAnswerDto(
      type: json['type']?.toString() ?? '',
      sdp: json['sdp']?.toString() ?? '',
      callId: callId ?? json['callId']?.toString(),
      messageId: messageId ?? json['messageId']?.toString(),
      generation: gen?.toInt() ?? generation,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'sdp': sdp,
        if (callId != null) 'callId': callId,
        if (messageId != null) 'messageId': messageId,
        'generation': generation,
      };
}

class VoiceCallRtcCandidateDto {
  const VoiceCallRtcCandidateDto({
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
    this.usernameFragment,
    this.callId,
    this.messageId,
    this.generation = 0,
  });

  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;
  final String? usernameFragment;
  final String? callId;
  final String? messageId;
  final int generation;

  factory VoiceCallRtcCandidateDto.fromJson(
    Map<String, dynamic> json, {
    String? callId,
    String? messageId,
    int generation = 0,
  }) {
    final gen = (json['negotiationGeneration'] ?? json['generation']) as num?;
    return VoiceCallRtcCandidateDto(
      candidate: json['candidate']?.toString() ?? '',
      sdpMid: json['sdpMid']?.toString(),
      sdpMLineIndex: (json['sdpMLineIndex'] as num?)?.toInt(),
      usernameFragment: json['usernameFragment']?.toString(),
      callId: callId ?? json['callId']?.toString(),
      messageId: messageId ?? json['messageId']?.toString(),
      generation: gen?.toInt() ?? generation,
    );
  }

  Map<String, dynamic> toJson() => {
        'candidate': candidate,
        if (sdpMid != null) 'sdpMid': sdpMid,
        if (sdpMLineIndex != null) 'sdpMLineIndex': sdpMLineIndex,
        if (usernameFragment != null) 'usernameFragment': usernameFragment,
        if (callId != null) 'callId': callId,
        if (messageId != null) 'messageId': messageId,
        'generation': generation,
      };
}
