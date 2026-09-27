import 'package:json_annotation/json_annotation.dart';

part 'driver_barcode_validation_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverBarcodeValidationResponseDto {
  const DriverBarcodeValidationResponseDto({
    this.boxId,
    this.boxCode,
    this.customerName,
    this.deliveryZone,
    this.mealsCount,
    this.deliveryTimeSlot,
    this.validationToken,
    this.expiresAtUtc,
    this.status,
    this.statusText,
    this.nextAction,
    this.message,
  });

  factory DriverBarcodeValidationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverBarcodeValidationResponseDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? customerName;
  final String? deliveryZone;
  final int? mealsCount;
  final String? deliveryTimeSlot;
  final String? validationToken;
  final String? expiresAtUtc;
  final String? status;
  final String? statusText;
  final String? nextAction;
  final String? message;
}
