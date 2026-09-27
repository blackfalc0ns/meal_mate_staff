import 'package:json_annotation/json_annotation.dart';

part 'driver_pickup_manifest_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverPickupManifestResponseDto {
  const DriverPickupManifestResponseDto({
    this.tripId,
    this.tripCode,
    this.driverId,
    this.driverName,
    this.totalBoxesCount,
    this.totalMealsCount,
    this.pendingScanBoxesCount,
    this.pickedUpBoxesCount,
    this.scannedBoxesCount,
    this.allBoxesPickedUp,
    this.canStartTrip,
    this.boxes,
  });

  factory DriverPickupManifestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverPickupManifestResponseDtoFromJson(json);

  final String? tripId;
  final String? tripCode;
  final String? driverId;
  final String? driverName;
  final int? totalBoxesCount;
  final int? totalMealsCount;
  final int? pendingScanBoxesCount;
  final int? pickedUpBoxesCount;
  final int? scannedBoxesCount;
  final bool? allBoxesPickedUp;
  final bool? canStartTrip;
  final List<DriverAssignedBoxResponseDto>? boxes;
}

@JsonSerializable(createToJson: false)
class DriverAssignedBoxResponseDto {
  const DriverAssignedBoxResponseDto({
    this.boxId,
    this.boxCode,
    this.customerName,
    this.deliveryZone,
    this.mealsCount,
    this.mealsSummary,
    this.deliveryTimeSlot,
    this.scanStatus,
    this.scanStatusText,
    this.isScanned,
    this.scannedAtUtc,
    this.conditionPhotoStorageKey,
  });

  factory DriverAssignedBoxResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverAssignedBoxResponseDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? customerName;
  final String? deliveryZone;
  final int? mealsCount;
  final String? mealsSummary;
  final String? deliveryTimeSlot;
  final String? scanStatus;
  final String? scanStatusText;
  final bool? isScanned;
  final String? scannedAtUtc;
  final String? conditionPhotoStorageKey;
}
