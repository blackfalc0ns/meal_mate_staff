import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/data_source/driver_pickup_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/request/confirm_driver_pickup_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/request/start_driver_trip_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/request/validate_driver_barcode_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_barcode_validation_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_condition_photo_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_pickup_confirmation_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_pickup_summary_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/data/models/response/driver_trip_start_response_dto.dart';

class _FakeApiServices implements ApiServices {
  ValidateDriverBarcodeRequestDto? validateRequest;
  String? uploadBoxId;
  File? uploadFile;
  String? uploadToken;
  String? confirmBoxId;
  String? confirmIdempotencyKey;
  ConfirmDriverPickupRequestDto? confirmRequest;
  String? summaryTripId;
  String? startTripId;
  String? startIdempotencyKey;
  StartDriverTripRequestDto? startRequest;

  @override
  Future<DriverBarcodeValidationResponseDto> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestDto request,
  ) async {
    validateRequest = request;
    return const DriverBarcodeValidationResponseDto(boxId: 'box-101');
  }

  @override
  Future<DriverConditionPhotoUploadResponseDto> uploadDriverBoxConditionPhoto(
    String boxId,
    File file,
    String validationToken,
  ) async {
    uploadBoxId = boxId;
    uploadFile = file;
    uploadToken = validationToken;
    return const DriverConditionPhotoUploadResponseDto(
      conditionPhotoStorageKey: 'key-123',
    );
  }

  @override
  Future<DriverPickupConfirmationResponseDto> confirmDriverBoxPickup(
    String boxId,
    String idempotencyKey,
    ConfirmDriverPickupRequestDto request,
  ) async {
    confirmBoxId = boxId;
    confirmIdempotencyKey = idempotencyKey;
    confirmRequest = request;
    return const DriverPickupConfirmationResponseDto(boxId: 'box-101');
  }

  @override
  Future<DriverPickupSummaryResponseDto> getDriverPickupSummary(
    String tripId,
  ) async {
    summaryTripId = tripId;
    return const DriverPickupSummaryResponseDto(tripId: 'trip-101');
  }

  @override
  Future<DriverTripStartResponseDto> startDriverTrip(
    String tripId,
    String idempotencyKey,
    StartDriverTripRequestDto request,
  ) async {
    startTripId = tripId;
    startIdempotencyKey = idempotencyKey;
    startRequest = request;
    return const DriverTripStartResponseDto(tripId: 'trip-101');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeApiServices fakeApi;
  late DriverPickupRemoteDataSourceImpl dataSource;

  setUp(() {
    fakeApi = _FakeApiServices();
    dataSource = DriverPickupRemoteDataSourceImpl(fakeApi);
  });

  group('DriverPickupRemoteDataSourceImpl', () {
    test('validateDriverPickupBarcode forwards request body', () async {
      const request = ValidateDriverBarcodeRequestDto(barcodeValue: 'BOX-101');
      final result = await dataSource.validateDriverPickupBarcode(request);

      expect(fakeApi.validateRequest?.barcodeValue, 'BOX-101');
      expect(result.boxId, 'box-101');
    });

    test('uploadDriverBoxConditionPhoto forwards boxId, file, and validationToken', () async {
      final file = File('test.jpg');
      final result = await dataSource.uploadDriverBoxConditionPhoto(
        boxId: 'box-101',
        file: file,
        validationToken: 'token-abc',
      );

      expect(fakeApi.uploadBoxId, 'box-101');
      expect(fakeApi.uploadFile, file);
      expect(fakeApi.uploadToken, 'token-abc');
      expect(result.conditionPhotoStorageKey, 'key-123');
    });

    test('confirmDriverBoxPickup forwards boxId, idempotencyKey, and body', () async {
      const request = ConfirmDriverPickupRequestDto(
        validationToken: 'token-abc',
        conditionPhotoStorageKey: 'key-123',
        latitude: 29.3375,
        longitude: 48.0280,
      );
      final result = await dataSource.confirmDriverBoxPickup(
        boxId: 'box-101',
        idempotencyKey: 'idem-key-1',
        request: request,
      );

      expect(fakeApi.confirmBoxId, 'box-101');
      expect(fakeApi.confirmIdempotencyKey, 'idem-key-1');
      expect(fakeApi.confirmRequest, request);
      expect(result.boxId, 'box-101');
    });

    test('getDriverPickupSummary forwards tripId', () async {
      final result = await dataSource.getDriverPickupSummary('trip-101');
      expect(fakeApi.summaryTripId, 'trip-101');
      expect(result.tripId, 'trip-101');
    });

    test('startDriverTrip forwards tripId, idempotencyKey, and request', () async {
      const request = StartDriverTripRequestDto(
        latitude: 29.3375,
        longitude: 48.0280,
      );
      final result = await dataSource.startDriverTrip(
        tripId: 'trip-101',
        idempotencyKey: 'idem-key-2',
        request: request,
      );

      expect(fakeApi.startTripId, 'trip-101');
      expect(fakeApi.startIdempotencyKey, 'idem-key-2');
      expect(fakeApi.startRequest, request);
      expect(result.tripId, 'trip-101');
    });
  });
}
