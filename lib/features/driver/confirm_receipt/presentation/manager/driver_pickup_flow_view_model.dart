import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/location_exception.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../../../../../core/services/driver_pickup_location_provider.dart';
import '../../../../../core/services/idempotency_key_factory.dart';
import '../../domain/entities/confirm_driver_pickup_request_entity.dart';
import '../../domain/entities/validate_driver_barcode_request_entity.dart';
import '../../domain/usecase/confirm_driver_box_pickup_usecase.dart';
import '../../domain/usecase/upload_driver_box_condition_photo_usecase.dart';
import '../../domain/usecase/validate_driver_pickup_barcode_usecase.dart';
import 'driver_pickup_flow_event.dart';
import 'driver_pickup_flow_state.dart';

@injectable
class DriverPickupFlowViewModel
    extends Bloc<DriverPickupFlowEvent, DriverPickupFlowState> {
  DriverPickupFlowViewModel({
    required this.validateBarcodeUseCase,
    required this.uploadPhotoUseCase,
    required this.confirmPickupUseCase,
    required this.locationProvider,
    required this.idempotencyKeyFactory,
  }) : super(const DriverPickupFlowState()) {
    on<ValidateBarcodeEvent>(_onValidateBarcode);
    on<StepChangedEvent>(_onStepChanged);
    on<PhotoSelectedEvent>(_onPhotoSelected);
    on<UploadPhotoEvent>(_onUploadPhoto);
    on<ConfirmPickupEvent>(_onConfirmPickup);
    on<RetryFailedStageEvent>(_onRetryFailedStage);
    on<ResetScanEvent>(_onResetScan);
  }

  final ValidateDriverPickupBarcodeUseCase validateBarcodeUseCase;
  final UploadDriverBoxConditionPhotoUseCase uploadPhotoUseCase;
  final ConfirmDriverBoxPickupUseCase confirmPickupUseCase;
  final DriverPickupLocationProvider locationProvider;
  final IdempotencyKeyFactory idempotencyKeyFactory;

  String? _lastAttemptedBarcode;

  void doIntent(DriverPickupFlowEvent event) => add(event);

  Future<void> _onValidateBarcode(
    ValidateBarcodeEvent event,
    Emitter<DriverPickupFlowState> emit,
  ) async {
    final barcode = event.barcodeValue.trim();
    if (barcode.isEmpty) {
      emit(
        state.copyWith(
          failure: Failure(
            errorMessage: 'Barcode value cannot be empty',
            code: 'empty_barcode',
          ),
        ),
      );
      return;
    }

    _lastAttemptedBarcode = barcode;
    emit(
      state.copyWith(
        isValidatingBarcode: true,
        stage: DriverPickupFlowStage.validatingBarcode,
        clearFailure: true,
      ),
    );

    final result = await validateBarcodeUseCase(
      ValidateDriverBarcodeRequestEntity(barcodeValue: barcode),
    );

    if (emit.isDone) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isValidatingBarcode: false,
            validatedBox: data,
            validationToken: data.validationToken,
            tokenExpiresAtUtc: data.expiresAtUtc,
            stage: DriverPickupFlowStage.barcodeValidated,
            clearFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isValidatingBarcode: false,
            stage: DriverPickupFlowStage.pendingScan,
            failure: failure,
          ),
        );
    }
  }

  void _onStepChanged(
    StepChangedEvent event,
    Emitter<DriverPickupFlowState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onPhotoSelected(
    PhotoSelectedEvent event,
    Emitter<DriverPickupFlowState> emit,
  ) {
    emit(state.copyWith(localPhotoPath: event.photoPath));
  }

  Future<void> _onUploadPhoto(
    UploadPhotoEvent event,
    Emitter<DriverPickupFlowState> emit,
  ) async {
    await _executeUploadPhoto(emit);
  }

  Future<String?> _executeUploadPhoto(Emitter<DriverPickupFlowState> emit) async {
    final boxId = state.validatedBox?.boxId;
    final token = state.validationToken;
    final photoPath = state.localPhotoPath;

    if (boxId == null || token == null || photoPath == null) {
      emit(
        state.copyWith(
          failure: Failure(
            errorMessage: 'Missing box, token, or photo path',
            code: 'missing_upload_prerequisites',
          ),
        ),
      );
      return null;
    }

    emit(
      state.copyWith(
        isUploadingPhoto: true,
        stage: DriverPickupFlowStage.uploadingPhoto,
        clearFailure: true,
      ),
    );

    final result = await uploadPhotoUseCase(
      boxId: boxId,
      file: File(photoPath),
      validationToken: token,
    );

    if (emit.isDone) return null;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            conditionPhotoStorageKey: data.conditionPhotoStorageKey,
            stage: DriverPickupFlowStage.photoUploaded,
            clearFailure: true,
          ),
        );
        return data.conditionPhotoStorageKey;
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isUploadingPhoto: false, failure: failure));
        return null;
    }
  }

  Future<void> _onConfirmPickup(
    ConfirmPickupEvent event,
    Emitter<DriverPickupFlowState> emit,
  ) async {
    final boxId = state.validatedBox?.boxId;
    final token = state.validationToken;

    if (boxId == null || token == null) {
      emit(
        state.copyWith(
          failure: Failure(
            errorMessage: 'Cannot confirm without validated box and token',
            code: 'missing_box_or_token',
          ),
        ),
      );
      return;
    }

    // If photo is not uploaded yet, perform upload first
    var photoStorageKey = state.conditionPhotoStorageKey;
    if (photoStorageKey == null || photoStorageKey.isEmpty) {
      photoStorageKey = await _executeUploadPhoto(emit);
      if (photoStorageKey == null || photoStorageKey.isEmpty || emit.isDone) {
        return;
      }
    }

    // Reuse or generate idempotency key
    final idempotencyKey =
        state.idempotencyKey ?? idempotencyKeyFactory.create();
    emit(state.copyWith(idempotencyKey: idempotencyKey));

    // Acquire GPS location
    DriverPickupCoordinates coordinates;
    try {
      coordinates = await locationProvider.getCurrentCoordinates();
    } on LocationServiceException catch (e) {
      emit(
        state.copyWith(
          isConfirmingPickup: false,
          failure: Failure(
            errorMessage: 'Location service error: ${e.type.name}',
            code: 'location_error',
          ),
        ),
      );
      return;
    } catch (e) {
      emit(
        state.copyWith(
          isConfirmingPickup: false,
          failure: Failure(errorMessage: e.toString(), code: 'location_error'),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isConfirmingPickup: true,
        stage: DriverPickupFlowStage.confirmingPickup,
        clearFailure: true,
      ),
    );

    final result = await confirmPickupUseCase(
      boxId: boxId,
      idempotencyKey: idempotencyKey,
      request: ConfirmDriverPickupRequestEntity(
        validationToken: token,
        conditionPhotoStorageKey: photoStorageKey,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      ),
    );

    if (emit.isDone) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isConfirmingPickup: false,
            stage: DriverPickupFlowStage.pickedUp,
            confirmation: data,
            clearFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isConfirmingPickup: false, failure: failure));
    }
  }

  Future<void> _onRetryFailedStage(
    RetryFailedStageEvent event,
    Emitter<DriverPickupFlowState> emit,
  ) async {
    if (state.requiresRescan) {
      add(const ResetScanEvent());
      return;
    }

    if (state.conditionPhotoStorageKey != null && state.validatedBox != null) {
      await _onConfirmPickup(const ConfirmPickupEvent(), emit);
    } else if (state.localPhotoPath != null && state.validatedBox != null) {
      await _onConfirmPickup(const ConfirmPickupEvent(), emit);
    } else if (_lastAttemptedBarcode != null && state.validatedBox == null) {
      await _onValidateBarcode(
        ValidateBarcodeEvent(_lastAttemptedBarcode!),
        emit,
      );
    }
  }

  void _onResetScan(ResetScanEvent event, Emitter<DriverPickupFlowState> emit) {
    _lastAttemptedBarcode = null;
    emit(const DriverPickupFlowState());
  }
}
