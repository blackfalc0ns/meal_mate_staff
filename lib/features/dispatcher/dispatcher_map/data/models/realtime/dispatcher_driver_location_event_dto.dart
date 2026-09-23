import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_driver_location_event_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDriverLocationEventDto {
  const DispatcherDriverLocationEventDto({
    this.driverId,
    this.latitude,
    this.longitude,
    this.heading,
    this.speed,
    this.timestamp,
    this.locationZone,
    this.remainingDistanceKm,
    this.remainingDistanceText,
  });

  final String? driverId;
  final double? latitude;
  final double? longitude;
  final double? heading;

  @JsonKey(readValue: _readSpeed)
  final double? speed;

  @JsonKey(readValue: _readRecordedAt)
  final String? timestamp;

  final String? locationZone;
  final double? remainingDistanceKm;
  final String? remainingDistanceText;

  static Object? _readSpeed(Map json, String key) =>
      json['speedKmh'] ?? json['speed'];

  static Object? _readRecordedAt(Map json, String key) =>
      json['recordedAtUtc'] ?? json['timestamp'];

  factory DispatcherDriverLocationEventDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DispatcherDriverLocationEventDtoFromJson(json);
}
