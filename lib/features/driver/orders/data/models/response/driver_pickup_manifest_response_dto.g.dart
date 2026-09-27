// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_pickup_manifest_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverPickupManifestResponseDto _$DriverPickupManifestResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPickupManifestResponseDto(
  tripId: json['tripId'] as String?,
  tripCode: json['tripCode'] as String?,
  driverId: json['driverId'] as String?,
  driverName: json['driverName'] as String?,
  totalBoxesCount: (json['totalBoxesCount'] as num?)?.toInt(),
  totalMealsCount: (json['totalMealsCount'] as num?)?.toInt(),
  pendingScanBoxesCount: (json['pendingScanBoxesCount'] as num?)?.toInt(),
  pickedUpBoxesCount: (json['pickedUpBoxesCount'] as num?)?.toInt(),
  scannedBoxesCount: (json['scannedBoxesCount'] as num?)?.toInt(),
  allBoxesPickedUp: json['allBoxesPickedUp'] as bool?,
  canStartTrip: json['canStartTrip'] as bool?,
  boxes: (json['boxes'] as List<dynamic>?)
      ?.map(
        (e) => DriverAssignedBoxResponseDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

DriverAssignedBoxResponseDto _$DriverAssignedBoxResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverAssignedBoxResponseDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  customerName: json['customerName'] as String?,
  deliveryZone: json['deliveryZone'] as String?,
  mealsCount: (json['mealsCount'] as num?)?.toInt(),
  mealsSummary: json['mealsSummary'] as String?,
  deliveryTimeSlot: json['deliveryTimeSlot'] as String?,
  scanStatus: json['scanStatus'] as String?,
  scanStatusText: json['scanStatusText'] as String?,
  isScanned: json['isScanned'] as bool?,
  scannedAtUtc: json['scannedAtUtc'] as String?,
  conditionPhotoStorageKey: json['conditionPhotoStorageKey'] as String?,
);
