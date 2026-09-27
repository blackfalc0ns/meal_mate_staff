import 'package:json_annotation/json_annotation.dart';

part 'confirm_driver_pickup_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class ConfirmDriverPickupRequestDto {
  const ConfirmDriverPickupRequestDto({
    required this.validationToken,
    required this.conditionPhotoStorageKey,
    required this.latitude,
    required this.longitude,
  });

  final String validationToken;
  final String conditionPhotoStorageKey;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$ConfirmDriverPickupRequestDtoToJson(this);
}
