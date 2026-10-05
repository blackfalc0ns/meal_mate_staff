import 'package:json_annotation/json_annotation.dart';

part 'driver_map_location_response_dto.g.dart';

@JsonSerializable()
class DriverMapLocationResponseDto {
  const DriverMapLocationResponseDto({
    this.latitude,
    this.longitude,
    this.label,
    this.source,
    this.recordedAtUtc,
    this.isStale,
    this.heading,
  });

  factory DriverMapLocationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverMapLocationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverMapLocationResponseDtoToJson(this);

  final double? latitude;
  final double? longitude;
  final String? label;
  final String? source;
  final String? recordedAtUtc;
  final bool? isStale;
  final double? heading;
}
