import 'package:json_annotation/json_annotation.dart';

part 'driver_support_add_photos_response_dto.g.dart';

@JsonSerializable()
class DriverSupportAddPhotosResponseDto {
  const DriverSupportAddPhotosResponseDto({
    this.issueId,
    this.status,
    this.evidenceUrls,
  });

  factory DriverSupportAddPhotosResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverSupportAddPhotosResponseDtoFromJson(json);

  final String? issueId;
  final String? status;
  final List<String>? evidenceUrls;

  Map<String, dynamic> toJson() =>
      _$DriverSupportAddPhotosResponseDtoToJson(this);
}
