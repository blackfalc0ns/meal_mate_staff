import 'package:json_annotation/json_annotation.dart';

part 'driver_handover_arrival_request_dto.g.dart';

@JsonSerializable()
class DriverHandoverArrivalRequestDto {
  const DriverHandoverArrivalRequestDto({
    required this.latitude,
    required this.longitude,
  });

  factory DriverHandoverArrivalRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverHandoverArrivalRequestDtoFromJson(json);

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$DriverHandoverArrivalRequestDtoToJson(this);
}
