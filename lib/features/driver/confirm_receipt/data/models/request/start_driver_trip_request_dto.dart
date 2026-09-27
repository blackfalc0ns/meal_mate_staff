import 'package:json_annotation/json_annotation.dart';

part 'start_driver_trip_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class StartDriverTripRequestDto {
  const StartDriverTripRequestDto({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$StartDriverTripRequestDtoToJson(this);
}
