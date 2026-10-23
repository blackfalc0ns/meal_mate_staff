import 'package:json_annotation/json_annotation.dart';

part 'voice_device_register_request_dto.g.dart';

@JsonSerializable()
class VoiceDeviceRegisterRequestDto {
  const VoiceDeviceRegisterRequestDto({
    required this.installationId,
    required this.platform,
    required this.fcmDeviceTokenId,
    this.capabilityVersion = 2,
    this.appVersion,
  });

  factory VoiceDeviceRegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceDeviceRegisterRequestDtoFromJson(json);

  final String installationId;
  final String platform;
  final String fcmDeviceTokenId;
  final int capabilityVersion;
  final String? appVersion;

  Map<String, dynamic> toJson() => _$VoiceDeviceRegisterRequestDtoToJson(this);
}
