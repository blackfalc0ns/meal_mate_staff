// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_pickup_summary_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverPickupSummaryResponseDto _$DriverPickupSummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPickupSummaryResponseDto(
  tripId: json['tripId'] as String?,
  tripCode: json['tripCode'] as String?,
  driverId: json['driverId'] as String?,
  driverName: json['driverName'] as String?,
  assignedBoxesCount: (json['assignedBoxesCount'] as num?)?.toInt(),
  validatedBoxesCount: (json['validatedBoxesCount'] as num?)?.toInt(),
  receivedBoxesCount: (json['receivedBoxesCount'] as num?)?.toInt(),
  totalBoxesCount: (json['totalBoxesCount'] as num?)?.toInt(),
  pickedUpBoxesCount: (json['pickedUpBoxesCount'] as num?)?.toInt(),
  allBoxesPickedUp: json['allBoxesPickedUp'] as bool?,
  canStartTrip: json['canStartTrip'] as bool?,
  boxes: (json['boxes'] as List<dynamic>?)
      ?.map(
        (e) => DriverPickupSummaryBoxResponseDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  message: json['message'] as String?,
);

DriverPickupSummaryBoxResponseDto _$DriverPickupSummaryBoxResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPickupSummaryBoxResponseDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  customerName: json['customerName'] as String?,
  deliveryZone: json['deliveryZone'] as String?,
  mealsCount: (json['mealsCount'] as num?)?.toInt(),
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  isReceived: json['isReceived'] as bool?,
  conditionPhotoStorageKey: json['conditionPhotoStorageKey'] as String?,
);
