import 'package:json_annotation/json_annotation.dart';

part 'restaurant_device_token_request_dto.g.dart';

@JsonSerializable()
class RestaurantDeviceTokenRequestDto {
  const RestaurantDeviceTokenRequestDto({
    required this.token,
    required this.platform,
    required this.deviceId,
  });

  factory RestaurantDeviceTokenRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDeviceTokenRequestDtoFromJson(json);

  final String token;
  final String platform;
  final String deviceId;

  Map<String, dynamic> toJson() =>
      _$RestaurantDeviceTokenRequestDtoToJson(this);
}
