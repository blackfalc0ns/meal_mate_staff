import 'dart:io';

import '../models/request/confirm_driver_pickup_request_dto.dart';
import '../models/request/start_driver_trip_request_dto.dart';
import '../models/request/validate_driver_barcode_request_dto.dart';
import '../models/response/driver_barcode_validation_response_dto.dart';
import '../models/response/driver_condition_photo_upload_response_dto.dart';
import '../models/response/driver_pickup_confirmation_response_dto.dart';
import '../models/response/driver_pickup_summary_response_dto.dart';
import '../models/response/driver_trip_start_response_dto.dart';

abstract interface class DriverPickupRemoteDataSource {
  Future<DriverBarcodeValidationResponseDto> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestDto request,
  );

  Future<DriverConditionPhotoUploadResponseDto> uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  });

  Future<DriverPickupConfirmationResponseDto> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestDto request,
  });

  Future<DriverPickupSummaryResponseDto> getDriverPickupSummary(
    String tripId,
  );

  Future<DriverTripStartResponseDto> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestDto request,
  });
}
