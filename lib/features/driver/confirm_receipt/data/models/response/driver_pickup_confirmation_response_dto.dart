import 'package:json_annotation/json_annotation.dart';

part 'driver_pickup_confirmation_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverPickupConfirmationResponseDto {
  const DriverPickupConfirmationResponseDto({
    this.boxId,
    this.boxCode,
    this.tripId,
    this.confirmedAtUtc,
    this.status,
    this.statusText,
    this.nextAction,
    this.pickedUpBoxesCount,
    this.totalBoxesCount,
    this.allBoxesPickedUp,
    this.message,
  });

  factory DriverPickupConfirmationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverPickupConfirmationResponseDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? tripId;
  final String? confirmedAtUtc;
  final String? status;
  final String? statusText;
  final String? nextAction;
  final int? pickedUpBoxesCount;
  final int? totalBoxesCount;
  final bool? allBoxesPickedUp;
  final String? message;
}
