import 'package:json_annotation/json_annotation.dart';

part 'driver_device_token_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverDeviceTokenRequestDto {
  const DriverDeviceTokenRequestDto({
    required this.token,
    required this.platform,
    required this.deviceId,
    this.registrationId,
  });

  factory DriverDeviceTokenRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDeviceTokenRequestDtoFromJson(json);

  final String token;
  final String platform;
  final String deviceId;
  final String? registrationId;

  Map<String, dynamic> toJson() => _$DriverDeviceTokenRequestDtoToJson(this);
}
