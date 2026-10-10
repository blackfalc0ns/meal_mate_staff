import 'package:json_annotation/json_annotation.dart';

part 'voice_call_initiate_request_dto.g.dart';

@JsonSerializable()
class VoiceCallInitiateRequestDto {
  const VoiceCallInitiateRequestDto({
    required this.tripStopId,
    required this.clientRequestId,
  });

  factory VoiceCallInitiateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallInitiateRequestDtoFromJson(json);

  final String tripStopId;
  final String clientRequestId;

  Map<String, dynamic> toJson() => _$VoiceCallInitiateRequestDtoToJson(this);
}
