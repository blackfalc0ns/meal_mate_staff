import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/confirm_driver_pickup_request_entity.dart';
import '../../domain/entities/driver_barcode_validation_entity.dart';
import '../../domain/entities/driver_condition_photo_upload_entity.dart';
import '../../domain/entities/driver_pickup_confirmation_entity.dart';
import '../../domain/entities/driver_pickup_summary_entity.dart';
import '../../domain/entities/driver_trip_start_entity.dart';
import '../../domain/entities/start_driver_trip_request_entity.dart';
import '../../domain/entities/validate_driver_barcode_request_entity.dart';
import '../../domain/repo/driver_pickup_repository.dart';
import '../data_source/driver_pickup_remote_data_source.dart';
import '../mapper/driver_pickup_mapper.dart';

@LazySingleton(as: DriverPickupRepository)
class DriverPickupRepositoryImpl implements DriverPickupRepository {
  const DriverPickupRepositoryImpl(this._remoteDataSource);

  final DriverPickupRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverBarcodeValidationEntity>> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestEntity request,
  ) {
    return safeApiCall<DriverBarcodeValidationEntity>(() async {
      final dto = await _remoteDataSource.validateDriverPickupBarcode(
        request.toDto(),
      );
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverConditionPhotoUploadEntity>>
  uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) {
    return safeApiCall<DriverConditionPhotoUploadEntity>(() async {
      final dto = await _remoteDataSource.uploadDriverBoxConditionPhoto(
        boxId: boxId,
        file: file,
        validationToken: validationToken,
      );
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverPickupConfirmationEntity>> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  }) {
    return safeApiCall<DriverPickupConfirmationEntity>(() async {
      final dto = await _remoteDataSource.confirmDriverBoxPickup(
        boxId: boxId,
        idempotencyKey: idempotencyKey,
        request: request.toDto(),
      );
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverPickupSummaryEntity>> getDriverPickupSummary(
    String tripId,
  ) {
    return safeApiCall<DriverPickupSummaryEntity>(() async {
      final dto = await _remoteDataSource.getDriverPickupSummary(tripId);
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverTripStartEntity>> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestEntity request,
  }) {
    return safeApiCall<DriverTripStartEntity>(() async {
      final dto = await _remoteDataSource.startDriverTrip(
        tripId: tripId,
        idempotencyKey: idempotencyKey,
        request: request.toDto(),
      );
      return dto.toEntity();
    });
  }
}
