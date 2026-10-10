import 'package:json_annotation/json_annotation.dart';

part 'driver_arrival_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DriverArrivalRequestDto {
  const DriverArrivalRequestDto({this.latitude, this.longitude});

  factory DriverArrivalRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverArrivalRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverArrivalRequestDtoToJson(this);

  final double? latitude;
  final double? longitude;
}
