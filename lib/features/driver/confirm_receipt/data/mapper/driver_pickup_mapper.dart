import '../../domain/entities/confirm_driver_pickup_request_entity.dart';
import '../../domain/entities/driver_barcode_validation_entity.dart';
import '../../domain/entities/driver_condition_photo_upload_entity.dart';
import '../../domain/entities/driver_pickup_confirmation_entity.dart';
import '../../domain/entities/driver_pickup_summary_entity.dart';
import '../../domain/entities/driver_trip_start_entity.dart';
import '../../domain/entities/start_driver_trip_request_entity.dart';
import '../../domain/entities/validate_driver_barcode_request_entity.dart';
import '../models/request/confirm_driver_pickup_request_dto.dart';
import '../models/request/start_driver_trip_request_dto.dart';
import '../models/request/validate_driver_barcode_request_dto.dart';
import '../models/response/driver_barcode_validation_response_dto.dart';
import '../models/response/driver_condition_photo_upload_response_dto.dart';
import '../models/response/driver_pickup_confirmation_response_dto.dart';
import '../models/response/driver_pickup_summary_response_dto.dart';
import '../models/response/driver_trip_start_response_dto.dart';

extension ValidateDriverBarcodeRequestEntityMapper
    on ValidateDriverBarcodeRequestEntity {
  ValidateDriverBarcodeRequestDto toDto() {
    return ValidateDriverBarcodeRequestDto(barcodeValue: barcodeValue);
  }
}

extension ConfirmDriverPickupRequestEntityMapper
    on ConfirmDriverPickupRequestEntity {
  ConfirmDriverPickupRequestDto toDto() {
    return ConfirmDriverPickupRequestDto(
      validationToken: validationToken,
      conditionPhotoStorageKey: conditionPhotoStorageKey,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

extension StartDriverTripRequestEntityMapper on StartDriverTripRequestEntity {
  StartDriverTripRequestDto toDto() {
    return StartDriverTripRequestDto(latitude: latitude, longitude: longitude);
  }
}

extension DriverBarcodeValidationResponseDtoMapper
    on DriverBarcodeValidationResponseDto {
  DriverBarcodeValidationEntity toEntity() {
    DateTime? parsedExpiry;
    if (expiresAtUtc != null && expiresAtUtc!.trim().isNotEmpty) {
      parsedExpiry = DateTime.tryParse(expiresAtUtc!);
    }

    final rawMeals = mealsCount ?? 0;

    return DriverBarcodeValidationEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      customerName: customerName ?? '',
      deliveryZone: deliveryZone ?? '',
      mealsCount: rawMeals < 0 ? 0 : rawMeals,
      deliveryTimeSlot: deliveryTimeSlot ?? '',
      validationToken: validationToken ?? '',
      expiresAtUtc: parsedExpiry,
      status: status ?? '',
      statusText: statusText ?? '',
      nextAction: nextAction ?? '',
      message: message,
    );
  }
}

extension DriverConditionPhotoUploadResponseDtoMapper
    on DriverConditionPhotoUploadResponseDto {
  DriverConditionPhotoUploadEntity toEntity() {
    DateTime? parsedUploadedAt;
    if (uploadedAtUtc != null && uploadedAtUtc!.trim().isNotEmpty) {
      parsedUploadedAt = DateTime.tryParse(uploadedAtUtc!);
    }

    return DriverConditionPhotoUploadEntity(
      boxId: boxId ?? '',
      conditionPhotoStorageKey: conditionPhotoStorageKey ?? '',
      uploadedAtUtc: parsedUploadedAt,
      status: status ?? '',
      statusText: statusText ?? '',
      nextAction: nextAction ?? '',
      message: message,
    );
  }
}

extension DriverPickupConfirmationResponseDtoMapper
    on DriverPickupConfirmationResponseDto {
  DriverPickupConfirmationEntity toEntity() {
    DateTime? parsedConfirmedAt;
    if (confirmedAtUtc != null && confirmedAtUtc!.trim().isNotEmpty) {
      parsedConfirmedAt = DateTime.tryParse(confirmedAtUtc!);
    }

    final rawPickedUp = pickedUpBoxesCount ?? 0;
    final rawTotal = totalBoxesCount ?? 0;

    return DriverPickupConfirmationEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      tripId: tripId ?? '',
      confirmedAtUtc: parsedConfirmedAt,
      status: status ?? '',
      statusText: statusText ?? '',
      nextAction: DriverPickupNextAction.fromString(nextAction),
      pickedUpBoxesCount: rawPickedUp < 0 ? 0 : rawPickedUp,
      totalBoxesCount: rawTotal < 0 ? 0 : rawTotal,
      allBoxesPickedUp: allBoxesPickedUp ?? false,
      message: message,
    );
  }
}

extension DriverPickupSummaryResponseDtoMapper
    on DriverPickupSummaryResponseDto {
  DriverPickupSummaryEntity toEntity() {
    final rawAssigned = assignedBoxesCount ?? 0;
    final rawValidated = validatedBoxesCount ?? 0;
    final rawReceived = receivedBoxesCount ?? 0;
    final rawTotal = totalBoxesCount ?? 0;
    final rawPickedUp = pickedUpBoxesCount ?? 0;

    return DriverPickupSummaryEntity(
      tripId: tripId ?? '',
      tripCode: tripCode ?? '',
      driverId: driverId ?? '',
      driverName: driverName ?? '',
      assignedBoxesCount: rawAssigned < 0 ? 0 : rawAssigned,
      validatedBoxesCount: rawValidated < 0 ? 0 : rawValidated,
      receivedBoxesCount: rawReceived < 0 ? 0 : rawReceived,
      totalBoxesCount: rawTotal < 0 ? 0 : rawTotal,
      pickedUpBoxesCount: rawPickedUp < 0 ? 0 : rawPickedUp,
      allBoxesPickedUp: allBoxesPickedUp ?? false,
      canStartTrip: canStartTrip ?? false,
      boxes: boxes?.map((b) => b.toEntity()).toList() ?? const [],
      message: message,
    );
  }
}

extension DriverPickupSummaryBoxResponseDtoMapper
    on DriverPickupSummaryBoxResponseDto {
  DriverPickupSummaryBoxEntity toEntity() {
    final rawMeals = mealsCount ?? 0;

    return DriverPickupSummaryBoxEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      customerName: customerName ?? '',
      deliveryZone: deliveryZone ?? '',
      mealsCount: rawMeals < 0 ? 0 : rawMeals,
      status: status ?? '',
      statusText: statusText ?? '',
      isReceived: isReceived ?? false,
      conditionPhotoStorageKey: conditionPhotoStorageKey,
    );
  }
}

extension DriverTripStartResponseDtoMapper on DriverTripStartResponseDto {
  DriverTripStartEntity toEntity() {
    DateTime? parsedStartedAt;
    if (startedAtUtc != null && startedAtUtc!.trim().isNotEmpty) {
      parsedStartedAt = DateTime.tryParse(startedAtUtc!);
    }

    return DriverTripStartEntity(
      tripId: tripId ?? '',
      tripCode: tripCode ?? '',
      startedAtUtc: parsedStartedAt,
      status: status ?? '',
      statusText: statusText ?? '',
      activeRouteId: activeRouteId ?? '',
      message: message,
    );
  }
}
