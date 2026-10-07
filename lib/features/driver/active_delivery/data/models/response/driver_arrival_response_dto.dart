import 'package:json_annotation/json_annotation.dart';

part 'driver_arrival_response_dto.g.dart';

@JsonSerializable()
class DriverArrivalResponseDto {
  const DriverArrivalResponseDto({
    this.boxId,
    this.arrivedAtUtc,
    this.isFirstArrival,
    this.status,
    this.statusText,
    this.message,
  });

  factory DriverArrivalResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverArrivalResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverArrivalResponseDtoToJson(this);

  final String? boxId;
  final String? arrivedAtUtc;
  final bool? isFirstArrival;
  final String? status;
  final String? statusText;
  final String? message;
}
