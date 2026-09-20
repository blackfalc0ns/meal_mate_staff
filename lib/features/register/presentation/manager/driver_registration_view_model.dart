import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../domain/usecase/get_driver_restaurants_usecase.dart';
import '../../domain/usecase/resubmit_driver_registration_usecase.dart';
import '../../domain/usecase/submit_driver_registration_usecase.dart';
import '../../domain/usecase/upload_driver_document_usecase.dart';
import 'driver_registration_event.dart';
import 'driver_registration_state.dart';

@injectable
class DriverRegistrationViewModel extends Cubit<DriverRegistrationState> {
  DriverRegistrationViewModel({
    required this.getRestaurantsUseCase,
    required this.uploadDocumentUseCase,
    required this.submitRegistrationUseCase,
    required this.resubmitRegistrationUseCase,
  }) : super(const DriverRegistrationState());

  final GetDriverRestaurantsUseCase getRestaurantsUseCase;
  final UploadDriverDocumentUseCase uploadDocumentUseCase;
  final SubmitDriverRegistrationUseCase submitRegistrationUseCase;
  final ResubmitDriverRegistrationUseCase resubmitRegistrationUseCase;

  void doIntent(DriverRegistrationEvent event) {
    switch (event) {
      case DriverRegistrationLoadRestaurantsEvent():
        _handleLoadRestaurants();
      case DriverRegistrationStepChangedEvent(:final step):
        _handleStepChanged(step);
      case DriverRegistrationPersonalDataUpdatedEvent(:final personalData):
        _handlePersonalDataUpdated(personalData);
      case DriverRegistrationVehicleDataUpdatedEvent(
        :final vehicleData,
        :final selectedColor,
        :final ownsVehicle,
      ):
        _handleVehicleDataUpdated(
          vehicleData,
          selectedColor: selectedColor,
          ownsVehicle: ownsVehicle,
        );
      case DriverRegistrationUploadDocumentEvent(
        :final documentId,
        :final file,
      ):
        _handleUploadDocument(documentId, file);
      case DriverRegistrationRemoveDocumentEvent(:final documentId):
        _handleRemoveDocument(documentId);
      case DriverRegistrationSubmitEvent():
        _handleSubmit();
      case DriverRegistrationResubmitEvent(
        :final registrationId,
        :final resubmitData,
      ):
        _handleResubmit(registrationId, resubmitData);
      case DriverRegistrationSetDraftEvent(:final draft):
        emit(state.copyWith(draft: draft));
    }
  }

  Future<void> _handleLoadRestaurants() async {
    emit(state.copyWith(status: DriverRegistrationStatus.loadingRestaurants));

    final result = await getRestaurantsUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        var updatedDraft = state.draft;
        if (updatedDraft.restaurantId.isEmpty && data.isNotEmpty) {
          updatedDraft = updatedDraft.copyWith(
            restaurantId: data.first.id,
            restaurantName: data.first.tradeName,
          );
        }
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.restaurantsLoaded,
            restaurants: data,
            draft: updatedDraft,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.error,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  void _handleStepChanged(int step) {
    emit(state.copyWith(currentStep: step));
  }

  void _handlePersonalDataUpdated(dynamic personalData) {
    // Ensure standard future ISO dates if omitted
    final defaultExpiry = DateTime.now()
        .add(const Duration(days: 365 * 5))
        .toIso8601String();

    final updatedDraft = state.draft.copyWith(
      restaurantId: personalData.restaurantId.isNotEmpty
          ? personalData.restaurantId
          : state.draft.restaurantId,
      restaurantName: personalData.restaurantName.isNotEmpty
          ? personalData.restaurantName
          : state.draft.restaurantName,
      fullNameAr: personalData.fullNameAr.isNotEmpty
          ? personalData.fullNameAr
          : '${personalData.firstName} ${personalData.lastName}'.trim(),
      fullNameEn: personalData.fullNameEn.isNotEmpty
          ? personalData.fullNameEn
          : '${personalData.firstName} ${personalData.lastName}'.trim(),
      phone: personalData.phone.isNotEmpty
          ? personalData.phone
          : state.draft.phone,
      email: personalData.email,
      nationalId: personalData.civilId.isNotEmpty
          ? personalData.civilId
          : state.draft.nationalId,
      nationalIdExpiry: personalData.nationalIdExpiry.isNotEmpty
          ? personalData.nationalIdExpiry
          : (state.draft.nationalIdExpiry.isNotEmpty
                ? state.draft.nationalIdExpiry
                : defaultExpiry),
      dateOfBirth: personalData.birthDate.isNotEmpty
          ? personalData.birthDate
          : state.draft.dateOfBirth,
      nationality: personalData.nationality.isNotEmpty
          ? personalData.nationality
          : state.draft.nationality,
    );

    emit(state.copyWith(draft: updatedDraft));
  }

  void _handleVehicleDataUpdated(
    dynamic vehicleData, {
    dynamic selectedColor,
    bool? ownsVehicle,
  }) {
    final defaultExpiry = DateTime.now()
        .add(const Duration(days: 365 * 3))
        .toIso8601String();

    final year =
        int.tryParse(vehicleData.manufactureYear) ?? state.draft.vehicleYear;

    final updatedDraft = state.draft.copyWith(
      vehicleType: vehicleData.type.isNotEmpty
          ? vehicleData.type
          : state.draft.vehicleType,
      vehicleModel: vehicleData.model.isNotEmpty
          ? vehicleData.model
          : state.draft.vehicleModel,
      vehiclePlate: vehicleData.plateNumber.isNotEmpty
          ? vehicleData.plateNumber
          : state.draft.vehiclePlate,
      vehicleYear: year,
      vehicleColor: vehicleData.color.isNotEmpty
          ? vehicleData.color
          : state.draft.vehicleColor,
      isVehicleOwned: ownsVehicle ?? vehicleData.isOwned,
      licenseNumber: vehicleData.licenseNumber.isNotEmpty
          ? vehicleData.licenseNumber
          : (state.draft.licenseNumber.isNotEmpty
                ? state.draft.licenseNumber
                : 'LIC-${vehicleData.plateNumber}'),
      licenseExpiry: vehicleData.licenseExpiry.isNotEmpty
          ? vehicleData.licenseExpiry
          : (state.draft.licenseExpiry.isNotEmpty
                ? state.draft.licenseExpiry
                : defaultExpiry),
      vehicleLicenseExpiry: vehicleData.vehicleLicenseExpiry.isNotEmpty
          ? vehicleData.vehicleLicenseExpiry
          : (state.draft.vehicleLicenseExpiry.isNotEmpty
                ? state.draft.vehicleLicenseExpiry
                : defaultExpiry),
      contractExpiry: vehicleData.contractExpiry ?? state.draft.contractExpiry,
    );

    emit(
      state.copyWith(
        draft: updatedDraft,
        selectedVehicleColor: selectedColor ?? state.selectedVehicleColor,
        ownsVehicle: ownsVehicle ?? state.ownsVehicle,
      ),
    );
  }

  Future<void> _handleUploadDocument(String documentId, dynamic file) async {
    // Set isUploading for this document
    final updatedDocs = state.documents.map((doc) {
      if (doc.id == documentId) {
        return doc.copyWith(
          isUploading: true,
          localFilePath: file.path,
          errorMessage: null,
        );
      }
      return doc;
    }).toList();

    emit(
      state.copyWith(
        status: DriverRegistrationStatus.uploadingDocument,
        documents: updatedDocs,
        uploadingDocumentId: documentId,
      ),
    );

    final result = await uploadDocumentUseCase(file);
    switch (result) {
      case ApiSuccessResult(:final data):
        final storageKey = data.storageKey;
        final finalDocs = state.documents.map((doc) {
          if (doc.id == documentId) {
            return doc.copyWith(
              isUploaded: true,
              storageKey: storageKey,
              localFilePath: file.path,
              fileName: data.fileName ?? file.uri.pathSegments.last,
              isUploading: false,
            );
          }
          return doc;
        }).toList();

        // Update draft storage keys
        var updatedDraft = state.draft;
        if (documentId == 'civil-card') {
          updatedDraft = updatedDraft.copyWith(
            nationalIdFrontStorageKey: storageKey,
            nationalIdBackStorageKey:
                updatedDraft.nationalIdBackStorageKey.isNotEmpty
                ? updatedDraft.nationalIdBackStorageKey
                : storageKey,
          );
        } else if (documentId == 'driving-license') {
          updatedDraft = updatedDraft.copyWith(
            drivingLicenseFrontStorageKey: storageKey,
            drivingLicenseBackStorageKey:
                updatedDraft.drivingLicenseBackStorageKey.isNotEmpty
                ? updatedDraft.drivingLicenseBackStorageKey
                : storageKey,
          );
        } else if (documentId == 'car-registration') {
          updatedDraft = updatedDraft.copyWith(
            vehicleRegistrationStorageKey: storageKey,
          );
        } else if (documentId == 'vehicle-photo') {
          updatedDraft = updatedDraft.copyWith(
            vehiclePhotoStorageKey: storageKey,
          );
        } else if (documentId == 'personal-photo') {
          updatedDraft = updatedDraft.copyWith(
            profileImageStorageKey: storageKey,
          );
        }

        emit(
          state.copyWith(
            status: DriverRegistrationStatus.documentUploaded,
            documents: finalDocs,
            draft: updatedDraft,
            clearUploading: true,
          ),
        );
      case ApiErrorResult(:final failure):
        final errorDocs = state.documents.map((doc) {
          if (doc.id == documentId) {
            return doc.copyWith(
              isUploading: false,
              errorMessage: failure.errorMessage,
            );
          }
          return doc;
        }).toList();

        emit(
          state.copyWith(
            status: DriverRegistrationStatus.error,
            documents: errorDocs,
            failure: failure,
            errorMessage: failure.errorMessage,
            clearUploading: true,
          ),
        );
    }
  }

  void _handleRemoveDocument(String documentId) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.id == documentId) {
        return doc.copyWith(
          isUploaded: false,
          storageKey: null,
          localFilePath: null,
        );
      }
      return doc;
    }).toList();

    var updatedDraft = state.draft;
    if (documentId == 'civil-card') {
      updatedDraft = updatedDraft.copyWith(
        nationalIdFrontStorageKey: '',
        nationalIdBackStorageKey: '',
      );
    } else if (documentId == 'driving-license') {
      updatedDraft = updatedDraft.copyWith(
        drivingLicenseFrontStorageKey: '',
        drivingLicenseBackStorageKey: '',
      );
    } else if (documentId == 'car-registration') {
      updatedDraft = updatedDraft.copyWith(vehicleRegistrationStorageKey: '');
    } else if (documentId == 'vehicle-photo') {
      updatedDraft = updatedDraft.copyWith(vehiclePhotoStorageKey: null);
    } else if (documentId == 'personal-photo') {
      updatedDraft = updatedDraft.copyWith(profileImageStorageKey: null);
    }

    emit(state.copyWith(documents: updatedDocs, draft: updatedDraft));
  }

  Future<void> _handleSubmit() async {
    if (state.isSubmitting) return;

    // Ensure fallback restaurant if available
    var draftToSubmit = state.draft;
    if (draftToSubmit.restaurantId.isEmpty && state.restaurants.isNotEmpty) {
      draftToSubmit = draftToSubmit.copyWith(
        restaurantId: state.restaurants.first.id,
        restaurantName: state.restaurants.first.tradeName,
      );
    }

    // Default dates if missing
    final defaultExpiry = DateTime.now()
        .add(const Duration(days: 365 * 4))
        .toIso8601String();
    if (draftToSubmit.nationalIdExpiry.isEmpty) {
      draftToSubmit = draftToSubmit.copyWith(nationalIdExpiry: defaultExpiry);
    }
    if (draftToSubmit.licenseExpiry.isEmpty) {
      draftToSubmit = draftToSubmit.copyWith(licenseExpiry: defaultExpiry);
    }
    if (draftToSubmit.vehicleLicenseExpiry.isEmpty) {
      draftToSubmit = draftToSubmit.copyWith(
        vehicleLicenseExpiry: defaultExpiry,
      );
    }

    emit(
      state.copyWith(
        status: DriverRegistrationStatus.submitting,
        draft: draftToSubmit,
      ),
    );

    final result = await submitRegistrationUseCase(draftToSubmit);
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.submissionSuccess,
            submissionResult: data,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.error,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _handleResubmit(
    String registrationId,
    dynamic resubmitData,
  ) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(status: DriverRegistrationStatus.resubmitting));

    final result = await resubmitRegistrationUseCase(
      registrationId: registrationId,
      resubmitData: resubmitData,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.resubmissionSuccess,
            submissionResult: data,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.error,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }
}
