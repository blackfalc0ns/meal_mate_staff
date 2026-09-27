import 'dart:io';

import '../../../../../core/network/api_results.dart';
import '../entities/confirm_driver_pickup_request_entity.dart';
import '../entities/driver_barcode_validation_entity.dart';
import '../entities/driver_condition_photo_upload_entity.dart';
import '../entities/driver_pickup_confirmation_entity.dart';
import '../entities/driver_pickup_summary_entity.dart';
import '../entities/driver_trip_start_entity.dart';
import '../entities/start_driver_trip_request_entity.dart';
import '../entities/validate_driver_barcode_request_entity.dart';

abstract interface class DriverPickupRepository {
  Future<ApiResult<DriverBarcodeValidationEntity>> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestEntity request,
  );

  Future<ApiResult<DriverConditionPhotoUploadEntity>> uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  });

  Future<ApiResult<DriverPickupConfirmationEntity>> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  });

  Future<ApiResult<DriverPickupSummaryEntity>> getDriverPickupSummary(
    String tripId,
  );

  Future<ApiResult<DriverTripStartEntity>> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestEntity request,
  });
}
