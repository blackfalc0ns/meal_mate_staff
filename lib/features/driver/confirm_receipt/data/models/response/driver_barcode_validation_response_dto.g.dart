// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_barcode_validation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverBarcodeValidationResponseDto _$DriverBarcodeValidationResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverBarcodeValidationResponseDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  customerName: json['customerName'] as String?,
  deliveryZone: json['deliveryZone'] as String?,
  mealsCount: (json['mealsCount'] as num?)?.toInt(),
  deliveryTimeSlot: json['deliveryTimeSlot'] as String?,
  validationToken: json['validationToken'] as String?,
  expiresAtUtc: json['expiresAtUtc'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  nextAction: json['nextAction'] as String?,
  message: json['message'] as String?,
);
