import 'package:json_annotation/json_annotation.dart';

part 'driver_deliver_response_dto.g.dart';

@JsonSerializable()
class DriverDeliverResponseDto {
  const DriverDeliverResponseDto({
    this.boxId,
    this.deliveredAtUtc,
    this.tripId,
    this.isTripCompleted,
    this.remainingStopsCount,
    this.driverId,
    this.isFirstDelivery,
    this.message,
  });

  factory DriverDeliverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDeliverResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverDeliverResponseDtoToJson(this);

  final String? boxId;
  final String? deliveredAtUtc;
  final String? tripId;
  final bool? isTripCompleted;
  final int? remainingStopsCount;
  final String? driverId;
  final bool? isFirstDelivery;
  final String? message;
}
