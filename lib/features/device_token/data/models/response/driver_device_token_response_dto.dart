import 'package:json_annotation/json_annotation.dart';

part 'driver_device_token_response_dto.g.dart';

@JsonSerializable()
class DriverDeviceTokenResponseDto {
  const DriverDeviceTokenResponseDto({
    this.fcmDeviceTokenId,
  });

  factory DriverDeviceTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDeviceTokenResponseDtoFromJson(json);

  final String? fcmDeviceTokenId;

  Map<String, dynamic> toJson() => _$DriverDeviceTokenResponseDtoToJson(this);
}
