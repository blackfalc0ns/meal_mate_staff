import 'package:json_annotation/json_annotation.dart';

part 'driver_call_proxy_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverCallProxyResponseDto {
  const DriverCallProxyResponseDto({
    this.boxId,
    this.callableUri,
    this.phoneNumber,
    this.expiresAtUtc,
  });

  factory DriverCallProxyResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverCallProxyResponseDtoFromJson(json);

  final String? boxId;
  final String? callableUri;
  final String? phoneNumber;
  final String? expiresAtUtc;
}
