import 'package:json_annotation/json_annotation.dart';

part 'driver_deliver_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverDeliverRequestDto {
  const DriverDeliverRequestDto({
    required this.proofPhotoStorageKey,
    this.latitude,
    this.longitude,
    this.deliveryOtp,
  });

  factory DriverDeliverRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDeliverRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverDeliverRequestDtoToJson(this);

  final String proofPhotoStorageKey;
  final double? latitude;
  final double? longitude;
  final String? deliveryOtp;
}
