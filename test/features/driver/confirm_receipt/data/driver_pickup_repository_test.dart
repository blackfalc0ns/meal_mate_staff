import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/data_source/driver_pickup_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/request/confirm_driver_pickup_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/request/start_driver_trip_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/request/validate_driver_barcode_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_barcode_validation_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_condition_photo_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_pickup_confirmation_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_pickup_summary_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_trip_start_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/repo/driver_pickup_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/confirm_driver_pickup_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/start_driver_trip_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/validate_driver_barcode_request_entity.dart';

class _FakePickupRemoteDataSource implements DriverPickupRemoteDataSource {
  bool shouldThrowDioError = false;

  @override
  Future<DriverBarcodeValidationResponseDto> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestDto request,
  ) async {
    _checkError();
    return const DriverBarcodeValidationResponseDto(
      boxId: 'box-101',
      boxCode: 'BOX-101',
      validationToken: 'token-val',
    );
  }

  @override
  Future<DriverConditionPhotoUploadResponseDto> uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) async {
    _checkError();
    return const DriverConditionPhotoUploadResponseDto(
      boxId: 'box-101',
      conditionPhotoStorageKey: 'key-uploaded',
    );
  }

  @override
  Future<DriverPickupConfirmationResponseDto> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestDto request,
  }) async {
    _checkError();
    return const DriverPickupConfirmationResponseDto(
      boxId: 'box-101',
      tripId: 'trip-101',
      nextAction: 'ShowBoxSuccess',
    );
  }

  @override
  Future<DriverPickupSummaryResponseDto> getDriverPickupSummary(
    String tripId,
  ) async {
    _checkError();
    return const DriverPickupSummaryResponseDto(
      tripId: 'trip-101',
      assignedBoxesCount: 5,
    );
  }

  @override
  Future<DriverTripStartResponseDto> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestDto request,
  }) async {
    _checkError();
    return const DriverTripStartResponseDto(
      tripId: 'trip-101',
      status: 'TripStarted',
    );
  }

  void _checkError() {
    if (shouldThrowDioError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
    }
  }
}

void main() {
  late _FakePickupRemoteDataSource fakeDataSource;
  late DriverPickupRepositoryImpl repository;

  setUp(() {
    fakeDataSource = _FakePickupRemoteDataSource();
    repository = DriverPickupRepositoryImpl(fakeDataSource);
  });

  group('DriverPickupRepositoryImpl', () {
    test('validateDriverPickupBarcode maps entity to DTO and returns success entity', () async {
      final result = await repository.validateDriverPickupBarcode(
        const ValidateDriverBarcodeRequestEntity(barcodeValue: 'BOX-101'),
      );

      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.boxId, 'box-101');
      expect(data.validationToken, 'token-val');
    });

    test('uploadDriverBoxConditionPhoto wraps call with safeApiCall', () async {
      final result = await repository.uploadDriverBoxConditionPhoto(
        boxId: 'box-101',
        file: File('dummy.jpg'),
        validationToken: 'token-val',
      );

      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.conditionPhotoStorageKey, 'key-uploaded');
    });

    test('confirmDriverBoxPickup wraps error with safeApiCall', () async {
      fakeDataSource.shouldThrowDioError = true;
      final result = await repository.confirmDriverBoxPickup(
        boxId: 'box-101',
        idempotencyKey: 'idem-1',
        request: const ConfirmDriverPickupRequestEntity(
          validationToken: 'token-val',
          conditionPhotoStorageKey: 'key',
          latitude: 29.3375,
          longitude: 48.0280,
        ),
      );

      expect(result, isA<ApiErrorResult>());
      expect((result as ApiErrorResult).failure, isA<ServerFailure>());
    });

    test('getDriverPickupSummary returns mapped summary entity', () async {
      final result = await repository.getDriverPickupSummary('trip-101');
      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.tripId, 'trip-101');
      expect(data.assignedBoxesCount, 5);
    });

    test('startDriverTrip returns mapped start entity', () async {
      final result = await repository.startDriverTrip(
        tripId: 'trip-101',
        idempotencyKey: 'idem-2',
        request: const StartDriverTripRequestEntity(
          latitude: 29.3375,
          longitude: 48.0280,
        ),
      );

      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.tripId, 'trip-101');
      expect(data.status, 'TripStarted');
    });
  });
}
