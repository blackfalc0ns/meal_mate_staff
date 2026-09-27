import 'package:json_annotation/json_annotation.dart';

part 'driver_pickup_summary_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverPickupSummaryResponseDto {
  const DriverPickupSummaryResponseDto({
    this.tripId,
    this.tripCode,
    this.driverId,
    this.driverName,
    this.assignedBoxesCount,
    this.validatedBoxesCount,
    this.receivedBoxesCount,
    this.totalBoxesCount,
    this.pickedUpBoxesCount,
    this.allBoxesPickedUp,
    this.canStartTrip,
    this.boxes,
    this.message,
  });

  factory DriverPickupSummaryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverPickupSummaryResponseDtoFromJson(json);

  final String? tripId;
  final String? tripCode;
  final String? driverId;
  final String? driverName;
  final int? assignedBoxesCount;
  final int? validatedBoxesCount;
  final int? receivedBoxesCount;
  final int? totalBoxesCount;
  final int? pickedUpBoxesCount;
  final bool? allBoxesPickedUp;
  final bool? canStartTrip;
  final List<DriverPickupSummaryBoxResponseDto>? boxes;
  final String? message;
}

@JsonSerializable(createToJson: false)
class DriverPickupSummaryBoxResponseDto {
  const DriverPickupSummaryBoxResponseDto({
    this.boxId,
    this.boxCode,
    this.customerName,
    this.deliveryZone,
    this.mealsCount,
    this.status,
    this.statusText,
    this.isReceived,
    this.conditionPhotoStorageKey,
  });

  factory DriverPickupSummaryBoxResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverPickupSummaryBoxResponseDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? customerName;
  final String? deliveryZone;
  final int? mealsCount;
  final String? status;
  final String? statusText;
  final bool? isReceived;
  final String? conditionPhotoStorageKey;
}
