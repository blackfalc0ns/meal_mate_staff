import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/confirm_driver_pickup_request_dto.dart';
import '../models/request/start_driver_trip_request_dto.dart';
import '../models/request/validate_driver_barcode_request_dto.dart';
import '../models/response/driver_barcode_validation_response_dto.dart';
import '../models/response/driver_condition_photo_upload_response_dto.dart';
import '../models/response/driver_pickup_confirmation_response_dto.dart';
import '../models/response/driver_pickup_summary_response_dto.dart';
import '../models/response/driver_trip_start_response_dto.dart';
import 'driver_pickup_remote_data_source.dart';

@Injectable(as: DriverPickupRemoteDataSource)
class DriverPickupRemoteDataSourceImpl implements DriverPickupRemoteDataSource {
  const DriverPickupRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverBarcodeValidationResponseDto> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestDto request,
  ) {
    return _apiServices.validateDriverPickupBarcode(request);
  }

  @override
  Future<DriverConditionPhotoUploadResponseDto> uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) {
    return _apiServices.uploadDriverBoxConditionPhoto(
      boxId,
      file,
      validationToken,
    );
  }

  @override
  Future<DriverPickupConfirmationResponseDto> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestDto request,
  }) {
    return _apiServices.confirmDriverBoxPickup(boxId, idempotencyKey, request);
  }

  @override
  Future<DriverPickupSummaryResponseDto> getDriverPickupSummary(String tripId) {
    return _apiServices.getDriverPickupSummary(tripId);
  }

  @override
  Future<DriverTripStartResponseDto> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestDto request,
  }) {
    return _apiServices.startDriverTrip(tripId, idempotencyKey, request);
  }
}
