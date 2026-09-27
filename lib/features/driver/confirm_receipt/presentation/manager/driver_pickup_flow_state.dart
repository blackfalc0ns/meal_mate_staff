import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_barcode_validation_entity.dart';
import '../../domain/entities/driver_pickup_confirmation_entity.dart';

enum DriverPickupFlowStage {
  pendingScan,
  validatingBarcode,
  barcodeValidated,
  uploadingPhoto,
  photoUploaded,
  confirmingPickup,
  pickedUp,
}

class DriverPickupFlowState {
  const DriverPickupFlowState({
    this.stage = DriverPickupFlowStage.pendingScan,
    this.currentStep = 1,
    this.validatedBox,
    this.validationToken,
    this.tokenExpiresAtUtc,
    this.localPhotoPath,
    this.conditionPhotoStorageKey,
    this.confirmation,
    this.isValidatingBarcode = false,
    this.isUploadingPhoto = false,
    this.isConfirmingPickup = false,
    this.failure,
    this.idempotencyKey,
  });

  final DriverPickupFlowStage stage;
  final int currentStep;
  final DriverBarcodeValidationEntity? validatedBox;
  final String? validationToken;
  final DateTime? tokenExpiresAtUtc;
  final String? localPhotoPath;
  final String? conditionPhotoStorageKey;
  final DriverPickupConfirmationEntity? confirmation;
  final bool isValidatingBarcode;
  final bool isUploadingPhoto;
  final bool isConfirmingPickup;
  final Failure? failure;
  final String? idempotencyKey;

  bool get isTokenExpired {
    if (tokenExpiresAtUtc == null) return false;
    return DateTime.now().toUtc().isAfter(tokenExpiresAtUtc!);
  }

  bool get isBarcodeValidated =>
      validationToken != null && validationToken!.isNotEmpty && !isTokenExpired;

  bool get canContinueToPhoto => isBarcodeValidated && !isValidatingBarcode;

  bool get canConfirmPickup =>
      isBarcodeValidated &&
      localPhotoPath != null &&
      localPhotoPath!.isNotEmpty &&
      !isUploadingPhoto &&
      !isConfirmingPickup;

  bool get requiresRescan {
    if (isTokenExpired) return true;
    if (failure != null) {
      final code = failure!.code.toLowerCase();
      final msg = failure!.errorMessage.toLowerCase();
      if (code.contains('expired') || msg.contains('expired')) return true;
      if (code.contains('invalid_token') || msg.contains('invalid token')) {
        return true;
      }
    }
    return false;
  }

  bool get isActionLoading =>
      isValidatingBarcode || isUploadingPhoto || isConfirmingPickup;

  DriverPickupFlowState copyWith({
    DriverPickupFlowStage? stage,
    int? currentStep,
    DriverBarcodeValidationEntity? validatedBox,
    String? validationToken,
    DateTime? tokenExpiresAtUtc,
    String? localPhotoPath,
    String? conditionPhotoStorageKey,
    DriverPickupConfirmationEntity? confirmation,
    bool? isValidatingBarcode,
    bool? isUploadingPhoto,
    bool? isConfirmingPickup,
    Failure? failure,
    bool clearFailure = false,
    String? idempotencyKey,
  }) {
    return DriverPickupFlowState(
      stage: stage ?? this.stage,
      currentStep: currentStep ?? this.currentStep,
      validatedBox: validatedBox ?? this.validatedBox,
      validationToken: validationToken ?? this.validationToken,
      tokenExpiresAtUtc: tokenExpiresAtUtc ?? this.tokenExpiresAtUtc,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      conditionPhotoStorageKey:
          conditionPhotoStorageKey ?? this.conditionPhotoStorageKey,
      confirmation: confirmation ?? this.confirmation,
      isValidatingBarcode: isValidatingBarcode ?? this.isValidatingBarcode,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isConfirmingPickup: isConfirmingPickup ?? this.isConfirmingPickup,
      failure: clearFailure ? null : (failure ?? this.failure),
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}
