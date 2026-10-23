import 'package:json_annotation/json_annotation.dart';

part 'driver_support_add_photos_request_dto.g.dart';

@JsonSerializable()
class DriverSupportAddPhotosRequestDto {
  const DriverSupportAddPhotosRequestDto({
    required this.storageKeys,
  });

  factory DriverSupportAddPhotosRequestDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverSupportAddPhotosRequestDtoFromJson(json);

  final List<String> storageKeys;

  Map<String, dynamic> toJson() =>
      _$DriverSupportAddPhotosRequestDtoToJson(this);
}
