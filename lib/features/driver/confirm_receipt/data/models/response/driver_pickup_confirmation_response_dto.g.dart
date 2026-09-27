// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_pickup_confirmation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverPickupConfirmationResponseDto
_$DriverPickupConfirmationResponseDtoFromJson(Map<String, dynamic> json) =>
    DriverPickupConfirmationResponseDto(
      boxId: json['boxId'] as String?,
      boxCode: json['boxCode'] as String?,
      tripId: json['tripId'] as String?,
      confirmedAtUtc: json['confirmedAtUtc'] as String?,
      status: json['status'] as String?,
      statusText: json['statusText'] as String?,
      nextAction: json['nextAction'] as String?,
      pickedUpBoxesCount: (json['pickedUpBoxesCount'] as num?)?.toInt(),
      totalBoxesCount: (json['totalBoxesCount'] as num?)?.toInt(),
      allBoxesPickedUp: json['allBoxesPickedUp'] as bool?,
      message: json['message'] as String?,
    );
