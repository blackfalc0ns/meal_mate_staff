import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/confirm_driver_pickup_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_barcode_validation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_condition_photo_upload_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_confirmation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_summary_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_trip_start_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/start_driver_trip_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/validate_driver_barcode_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/repo/driver_pickup_repository.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/confirm_driver_box_pickup_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/get_driver_pickup_summary_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/start_driver_trip_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/upload_driver_box_condition_photo_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/validate_driver_pickup_barcode_usecase.dart';

class _FakeDriverPickupRepository implements DriverPickupRepository {
  ValidateDriverBarcodeRequestEntity? lastValidateRequest;
  String? lastUploadBoxId;
  File? lastUploadFile;
  String? lastUploadToken;
  String? lastConfirmBoxId;
  String? lastConfirmIdempotencyKey;
  ConfirmDriverPickupRequestEntity? lastConfirmRequest;
  String? lastSummaryTripId;
  String? lastStartTripId;
  String? lastStartIdempotencyKey;
  StartDriverTripRequestEntity? lastStartRequest;

  @override
  Future<ApiResult<DriverBarcodeValidationEntity>> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestEntity request,
  ) async {
    lastValidateRequest = request;
    return const ApiSuccessResult(
      data: DriverBarcodeValidationEntity(
        boxId: 'box-101',
        boxCode: 'BOX-101',
        customerName: 'Ahmad',
        deliveryZone: 'Hawalli',
        mealsCount: 2,
        deliveryTimeSlot: '12:00 - 14:00',
        validationToken: 'token-val',
        expiresAtUtc: null,
        status: 'Validated',
        statusText: 'Validated',
        nextAction: 'TakeConditionPhoto',
      ),
    );
  }

  @override
  Future<ApiResult<DriverConditionPhotoUploadEntity>>
  uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) async {
    lastUploadBoxId = boxId;
    lastUploadFile = file;
    lastUploadToken = validationToken;
    return const ApiSuccessResult(
      data: DriverConditionPhotoUploadEntity(
        boxId: 'box-101',
        conditionPhotoStorageKey: 'key-123',
        uploadedAtUtc: null,
        status: 'Uploaded',
        statusText: 'Uploaded',
        nextAction: 'ConfirmPickup',
      ),
    );
  }

  @override
  Future<ApiResult<DriverPickupConfirmationEntity>> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  }) async {
    lastConfirmBoxId = boxId;
    lastConfirmIdempotencyKey = idempotencyKey;
    lastConfirmRequest = request;
    return const ApiSuccessResult(
      data: DriverPickupConfirmationEntity(
        boxId: 'box-101',
        boxCode: 'BOX-101',
        tripId: 'trip-101',
        confirmedAtUtc: null,
        status: 'PickedUp',
        statusText: 'PickedUp',
        nextAction: DriverPickupNextAction.showBoxSuccess,
        pickedUpBoxesCount: 1,
        totalBoxesCount: 5,
        allBoxesPickedUp: false,
      ),
    );
  }

  @override
  Future<ApiResult<DriverPickupSummaryEntity>> getDriverPickupSummary(
    String tripId,
  ) async {
    lastSummaryTripId = tripId;
    return const ApiSuccessResult(
      data: DriverPickupSummaryEntity(
        tripId: 'trip-101',
        tripCode: 'TRIP-101',
        driverId: 'driver-1',
        driverName: 'Driver Name',
        assignedBoxesCount: 5,
        validatedBoxesCount: 5,
        receivedBoxesCount: 5,
        totalBoxesCount: 5,
        pickedUpBoxesCount: 5,
        allBoxesPickedUp: true,
        canStartTrip: true,
        boxes: [],
      ),
    );
  }

  @override
  Future<ApiResult<DriverTripStartEntity>> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestEntity request,
  }) async {
    lastStartTripId = tripId;
    lastStartIdempotencyKey = idempotencyKey;
    lastStartRequest = request;
    return const ApiSuccessResult(
      data: DriverTripStartEntity(
        tripId: 'trip-101',
        tripCode: 'TRIP-101',
        startedAtUtc: null,
        status: 'TripStarted',
        statusText: 'TripStarted',
        activeRouteId: 'route-1',
      ),
    );
  }
}

void main() {
  late _FakeDriverPickupRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeDriverPickupRepository();
  });

  group('Driver pickup use cases', () {
    test(
      'ValidateDriverPickupBarcodeUseCase delegates to repository',
      () async {
        final useCase = ValidateDriverPickupBarcodeUseCase(fakeRepo);
        const request = ValidateDriverBarcodeRequestEntity(
          barcodeValue: 'BOX-101',
        );
        final result = await useCase(request);

        expect(fakeRepo.lastValidateRequest, request);
        expect(result, isA<ApiSuccessResult<DriverBarcodeValidationEntity>>());
      },
    );

    test(
      'UploadDriverBoxConditionPhotoUseCase delegates to repository',
      () async {
        final useCase = UploadDriverBoxConditionPhotoUseCase(fakeRepo);
        final file = File('test.jpg');
        final result = await useCase(
          boxId: 'box-101',
          file: file,
          validationToken: 'token-abc',
        );

        expect(fakeRepo.lastUploadBoxId, 'box-101');
        expect(fakeRepo.lastUploadFile, file);
        expect(fakeRepo.lastUploadToken, 'token-abc');
        expect(
          result,
          isA<ApiSuccessResult<DriverConditionPhotoUploadEntity>>(),
        );
      },
    );

    test('ConfirmDriverBoxPickupUseCase delegates to repository', () async {
      final useCase = ConfirmDriverBoxPickupUseCase(fakeRepo);
      const request = ConfirmDriverPickupRequestEntity(
        validationToken: 'token-abc',
        conditionPhotoStorageKey: 'key-123',
        latitude: 29.3375,
        longitude: 48.0280,
      );
      final result = await useCase(
        boxId: 'box-101',
        idempotencyKey: 'idem-1',
        request: request,
      );

      expect(fakeRepo.lastConfirmBoxId, 'box-101');
      expect(fakeRepo.lastConfirmIdempotencyKey, 'idem-1');
      expect(fakeRepo.lastConfirmRequest, request);
      expect(result, isA<ApiSuccessResult<DriverPickupConfirmationEntity>>());
    });

    test('GetDriverPickupSummaryUseCase delegates to repository', () async {
      final useCase = GetDriverPickupSummaryUseCase(fakeRepo);
      final result = await useCase('trip-101');

      expect(fakeRepo.lastSummaryTripId, 'trip-101');
      expect(result, isA<ApiSuccessResult<DriverPickupSummaryEntity>>());
    });

    test('StartDriverTripUseCase delegates to repository', () async {
      final useCase = StartDriverTripUseCase(fakeRepo);
      const request = StartDriverTripRequestEntity(
        latitude: 29.3375,
        longitude: 48.0280,
      );
      final result = await useCase(
        tripId: 'trip-101',
        idempotencyKey: 'idem-2',
        request: request,
      );

      expect(fakeRepo.lastStartTripId, 'trip-101');
      expect(fakeRepo.lastStartIdempotencyKey, 'idem-2');
      expect(fakeRepo.lastStartRequest, request);
      expect(result, isA<ApiSuccessResult<DriverTripStartEntity>>());
    });
  });
}
