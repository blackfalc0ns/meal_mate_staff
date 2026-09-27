import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/services/idempotency_key_factory.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/confirm_driver_pickup_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_barcode_validation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_condition_photo_upload_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_confirmation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/validate_driver_barcode_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/repo/driver_pickup_repository.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/confirm_driver_box_pickup_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/upload_driver_box_condition_photo_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/validate_driver_pickup_barcode_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_event.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_state.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_view_model.dart';

import '../../../../support/fakes/fake_driver_pickup_location_provider.dart';

class _FakeRepository implements DriverPickupRepository {
  ApiResult<DriverBarcodeValidationEntity>? validateResult;
  ApiResult<DriverConditionPhotoUploadEntity>? uploadResult;
  ApiResult<DriverPickupConfirmationEntity>? confirmResult;

  int confirmCalls = 0;
  List<String> confirmedIdempotencyKeys = [];

  @override
  Future<ApiResult<DriverBarcodeValidationEntity>> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestEntity request,
  ) async {
    return validateResult!;
  }

  @override
  Future<ApiResult<DriverConditionPhotoUploadEntity>> uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) async {
    return uploadResult!;
  }

  @override
  Future<ApiResult<DriverPickupConfirmationEntity>> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  }) async {
    confirmCalls++;
    confirmedIdempotencyKeys.add(idempotencyKey);
    return confirmResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedIdempotencyKeyFactory implements IdempotencyKeyFactory {
  int _counter = 0;

  @override
  String create() {
    _counter++;
    return 'key-$_counter';
  }
}

void main() {
  late _FakeRepository fakeRepo;
  late FakeDriverPickupLocationProvider fakeLocation;
  late _FixedIdempotencyKeyFactory fakeKeyFactory;
  late ValidateDriverPickupBarcodeUseCase validateUseCase;
  late UploadDriverBoxConditionPhotoUseCase uploadUseCase;
  late ConfirmDriverBoxPickupUseCase confirmUseCase;
  late DriverPickupFlowViewModel viewModel;

  setUp(() {
    fakeRepo = _FakeRepository();
    fakeLocation = FakeDriverPickupLocationProvider();
    fakeKeyFactory = _FixedIdempotencyKeyFactory();
    validateUseCase = ValidateDriverPickupBarcodeUseCase(fakeRepo);
    uploadUseCase = UploadDriverBoxConditionPhotoUseCase(fakeRepo);
    confirmUseCase = ConfirmDriverBoxPickupUseCase(fakeRepo);

    viewModel = DriverPickupFlowViewModel(
      validateBarcodeUseCase: validateUseCase,
      uploadPhotoUseCase: uploadUseCase,
      confirmPickupUseCase: confirmUseCase,
      locationProvider: fakeLocation,
      idempotencyKeyFactory: fakeKeyFactory,
    );
  });

  tearDown(() {
    viewModel.close();
  });

  group('DriverPickupFlowViewModel', () {
    test('initial state is pendingScan at step 1 without failure', () {
      expect(viewModel.state.stage, DriverPickupFlowStage.pendingScan);
      expect(viewModel.state.currentStep, 1);
      expect(viewModel.state.failure, isNull);
      expect(viewModel.state.canContinueToPhoto, isFalse);
    });

    test('barcode success -> BarcodeValidated and step ready', () async {
      fakeRepo.validateResult = const ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'token-valid',
          expiresAtUtc: null,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );

      viewModel.doIntent(const ValidateBarcodeEvent('BOX-101'));
      await pumpEventQueue();

      expect(viewModel.state.stage, DriverPickupFlowStage.barcodeValidated);
      expect(viewModel.state.validatedBox?.boxCode, 'BOX-101');
      expect(viewModel.state.validationToken, 'token-valid');
      expect(viewModel.state.canContinueToPhoto, isTrue);
      expect(viewModel.state.failure, isNull);
    });

    test('invalid barcode -> remains scanner with Failure', () async {
      fakeRepo.validateResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Invalid barcode value', code: 'invalid_barcode'),
      );

      viewModel.doIntent(const ValidateBarcodeEvent('INVALID'));
      await pumpEventQueue();

      expect(viewModel.state.stage, DriverPickupFlowStage.pendingScan);
      expect(viewModel.state.validationToken, isNull);
      expect(viewModel.state.canContinueToPhoto, isFalse);
      expect(viewModel.state.failure?.errorMessage, 'Invalid barcode value');
    });

    test('photo selected and upload success -> PhotoUploaded', () async {
      fakeRepo.validateResult = const ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'token-valid',
          expiresAtUtc: null,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );
      viewModel.doIntent(const ValidateBarcodeEvent('BOX-101'));
      await pumpEventQueue();

      viewModel.doIntent(const StepChangedEvent(2));
      viewModel.doIntent(const PhotoSelectedEvent('path/to/local/photo.jpg'));
      await pumpEventQueue();
      expect(viewModel.state.localPhotoPath, 'path/to/local/photo.jpg');

      fakeRepo.uploadResult = const ApiSuccessResult(
        data: DriverConditionPhotoUploadEntity(
          boxId: 'box-101',
          conditionPhotoStorageKey: 'storage-key-777',
          uploadedAtUtc: null,
          status: 'Uploaded',
          statusText: 'Uploaded',
          nextAction: 'ConfirmPickup',
        ),
      );

      viewModel.doIntent(const UploadPhotoEvent());
      await pumpEventQueue();

      expect(viewModel.state.stage, DriverPickupFlowStage.photoUploaded);
      expect(viewModel.state.conditionPhotoStorageKey, 'storage-key-777');
      expect(viewModel.state.canConfirmPickup, isTrue);
    });

    test('expired token -> requiresRescan is true and clears token', () async {
      final expiredDate = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      fakeRepo.validateResult = ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'token-expired',
          expiresAtUtc: expiredDate,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );

      viewModel.doIntent(const ValidateBarcodeEvent('BOX-101'));
      await pumpEventQueue();

      expect(viewModel.state.isTokenExpired, isTrue);
      expect(viewModel.state.canContinueToPhoto, isFalse);
      expect(viewModel.state.requiresRescan, isTrue);
    });

    test('confirm retry -> reuses the same idempotency key', () async {
      fakeRepo.validateResult = const ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'token-valid',
          expiresAtUtc: null,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );
      viewModel.doIntent(const ValidateBarcodeEvent('BOX-101'));
      await pumpEventQueue();

      viewModel.doIntent(const StepChangedEvent(2));
      viewModel.doIntent(const PhotoSelectedEvent('path/to/photo.jpg'));

      fakeRepo.uploadResult = const ApiSuccessResult(
        data: DriverConditionPhotoUploadEntity(
          boxId: 'box-101',
          conditionPhotoStorageKey: 'key-1',
          uploadedAtUtc: null,
          status: 'Uploaded',
          statusText: 'Uploaded',
          nextAction: 'ConfirmPickup',
        ),
      );

      // First confirm fails
      fakeRepo.confirmResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Network timeout', code: 'timeout'),
      );

      viewModel.doIntent(const ConfirmPickupEvent());
      await pumpEventQueue();

      expect(fakeRepo.confirmCalls, 1);
      final firstKey = fakeRepo.confirmedIdempotencyKeys.first;
      expect(viewModel.state.idempotencyKey, firstKey);
      expect(viewModel.state.failure?.errorMessage, 'Network timeout');

      // Retry confirm
      fakeRepo.confirmResult = const ApiSuccessResult(
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

      viewModel.doIntent(const RetryFailedStageEvent());
      await pumpEventQueue();

      expect(fakeRepo.confirmCalls, 2);
      expect(fakeRepo.confirmedIdempotencyKeys[1], firstKey);
      expect(viewModel.state.stage, DriverPickupFlowStage.pickedUp);
      expect(viewModel.state.confirmation?.nextAction, DriverPickupNextAction.showBoxSuccess);
    });

    test('confirmation ShowPickupSummary -> nextAction indicates summary navigation', () async {
      fakeRepo.validateResult = const ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-105',
          boxCode: 'BOX-105',
          customerName: 'Sara',
          deliveryZone: 'Salmiya',
          mealsCount: 3,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'token-5',
          expiresAtUtc: null,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );
      viewModel.doIntent(const ValidateBarcodeEvent('BOX-105'));
      await pumpEventQueue();

      viewModel.doIntent(const StepChangedEvent(2));
      viewModel.doIntent(const PhotoSelectedEvent('path/to/photo5.jpg'));

      fakeRepo.uploadResult = const ApiSuccessResult(
        data: DriverConditionPhotoUploadEntity(
          boxId: 'box-105',
          conditionPhotoStorageKey: 'key-5',
          uploadedAtUtc: null,
          status: 'Uploaded',
          statusText: 'Uploaded',
          nextAction: 'ConfirmPickup',
        ),
      );

      fakeRepo.confirmResult = const ApiSuccessResult(
        data: DriverPickupConfirmationEntity(
          boxId: 'box-105',
          boxCode: 'BOX-105',
          tripId: 'trip-101',
          confirmedAtUtc: null,
          status: 'PickedUp',
          statusText: 'PickedUp',
          nextAction: DriverPickupNextAction.showPickupSummary,
          pickedUpBoxesCount: 5,
          totalBoxesCount: 5,
          allBoxesPickedUp: true,
        ),
      );

      viewModel.doIntent(const ConfirmPickupEvent());
      await pumpEventQueue();

      expect(viewModel.state.stage, DriverPickupFlowStage.pickedUp);
      expect(viewModel.state.confirmation?.nextAction, DriverPickupNextAction.showPickupSummary);
      expect(viewModel.state.confirmation?.allBoxesPickedUp, isTrue);
    });

    test('resetScan resets all state back to step 1 pendingScan', () async {
      fakeRepo.validateResult = const ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'token-valid',
          expiresAtUtc: null,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );
      viewModel.doIntent(const ValidateBarcodeEvent('BOX-101'));
      await pumpEventQueue();

      expect(viewModel.state.stage, DriverPickupFlowStage.barcodeValidated);

      viewModel.doIntent(const ResetScanEvent());
      await pumpEventQueue();

      expect(viewModel.state.stage, DriverPickupFlowStage.pendingScan);
      expect(viewModel.state.currentStep, 1);
      expect(viewModel.state.validatedBox, isNull);
      expect(viewModel.state.validationToken, isNull);
      expect(viewModel.state.localPhotoPath, isNull);
      expect(viewModel.state.conditionPhotoStorageKey, isNull);
      expect(viewModel.state.failure, isNull);
    });
  });
}
