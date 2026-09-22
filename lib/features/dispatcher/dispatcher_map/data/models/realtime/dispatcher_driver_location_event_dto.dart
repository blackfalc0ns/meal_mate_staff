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
  final double? speed;
  final String? timestamp;
  final String? locationZone;
  final double? remainingDistanceKm;
  final String? remainingDistanceText;

  factory DispatcherDriverLocationEventDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DispatcherDriverLocationEventDtoFromJson(json);
}
