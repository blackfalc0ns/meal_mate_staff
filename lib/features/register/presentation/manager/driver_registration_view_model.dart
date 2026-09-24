import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../../../core/network/failures.dart';
import '../../domain/usecase/get_driver_restaurants_usecase.dart';
import '../../domain/usecase/get_driver_nationalities_usecase.dart';
import '../../domain/usecase/get_driver_vehicle_colors_usecase.dart';
import '../../domain/usecase/get_driver_vehicle_types_usecase.dart';
import '../../domain/usecase/resubmit_driver_registration_usecase.dart';
import '../../domain/usecase/search_driver_vehicle_models_usecase.dart';
import '../../domain/usecase/submit_driver_registration_usecase.dart';
import '../../domain/usecase/upload_driver_document_usecase.dart';
import '../../domain/register_personal_data.dart';
import 'driver_registration_event.dart';
import 'driver_registration_state.dart';

enum _VehicleCatalogOperation { vehicleTypes, vehicleColors, vehicleModels }

@injectable
class DriverRegistrationViewModel extends Cubit<DriverRegistrationState> {
  DriverRegistrationViewModel({
    required this.getRestaurantsUseCase,
    required this.getNationalitiesUseCase,
    required this.getVehicleTypesUseCase,
    required this.getVehicleColorsUseCase,
    required this.searchVehicleModelsUseCase,
    required this.uploadDocumentUseCase,
    required this.submitRegistrationUseCase,
    required this.resubmitRegistrationUseCase,
  }) : super(const DriverRegistrationState());

  final GetDriverRestaurantsUseCase getRestaurantsUseCase;
  final GetDriverNationalitiesUseCase getNationalitiesUseCase;
  final GetDriverVehicleTypesUseCase getVehicleTypesUseCase;
  final GetDriverVehicleColorsUseCase getVehicleColorsUseCase;
  final SearchDriverVehicleModelsUseCase searchVehicleModelsUseCase;
  final UploadDriverDocumentUseCase uploadDocumentUseCase;
  final SubmitDriverRegistrationUseCase submitRegistrationUseCase;
  final ResubmitDriverRegistrationUseCase resubmitRegistrationUseCase;
  int _vehicleModelRequestIdentity = 0;
  String? _activeVehicleModelSearch;
  String? _activeVehicleModelType;
  int _activeVehicleModelLimit = 40;
  final Map<_VehicleCatalogOperation, Failure> _vehicleCatalogFailures = {};

  Failure? get _visibleVehicleCatalogFailure {
    for (final operation in _VehicleCatalogOperation.values) {
      final failure = _vehicleCatalogFailures[operation];
      if (failure != null) return failure;
    }
    return null;
  }

  void doIntent(DriverRegistrationEvent event) {
    switch (event) {
      case DriverRegistrationLoadRestaurantsEvent():
        _handleLoadRestaurants();
      case DriverRegistrationLoadNationalitiesEvent():
        _handleLoadNationalities();
      case DriverRegistrationLoadVehicleTypesEvent():
        _handleLoadVehicleTypes();
      case DriverRegistrationLoadVehicleColorsEvent():
        _handleLoadVehicleColors();
      case DriverRegistrationSearchVehicleModelsEvent(
        :final search,
        :final vehicleType,
        :final limit,
      ):
        _handleSearchVehicleModels(
          search: search,
          vehicleType: vehicleType,
          limit: limit,
        );
      case DriverRegistrationVehicleModelQueryChangedEvent(
        :final search,
        :final vehicleType,
      ):
        _handleVehicleModelQueryChanged(
          search: search,
          vehicleType: vehicleType,
        );
      case DriverRegistrationRetryVehicleCatalogEvent():
        _handleRetryVehicleCatalog();
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
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.restaurantsLoaded,
            restaurants: data,
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

  Future<void> _handleLoadNationalities() async {
    emit(state.copyWith(status: DriverRegistrationStatus.loadingNationalities));
    final result = await getNationalitiesUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: DriverRegistrationStatus.nationalitiesLoaded,
            nationalities: data,
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

  Future<void> _handleLoadVehicleTypes({
    bool preserveExistingFailure = false,
  }) async {
    if (!preserveExistingFailure) {
      _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleTypes);
    }
    final visibleFailure = _visibleVehicleCatalogFailure;
    emit(
      state.copyWith(
        isLoadingVehicleTypes: true,
        vehicleCatalogFailure: visibleFailure,
        clearVehicleCatalogFailure: visibleFailure == null,
      ),
    );

    final result = await getVehicleTypesUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleTypes);
        final remainingFailure = _visibleVehicleCatalogFailure;
        emit(
          state.copyWith(
            vehicleTypes: data,
            isLoadingVehicleTypes: false,
            vehicleCatalogFailure: remainingFailure,
            clearVehicleCatalogFailure: remainingFailure == null,
          ),
        );
      case ApiErrorResult(:final failure):
        _vehicleCatalogFailures[_VehicleCatalogOperation.vehicleTypes] =
            failure;
        emit(
          state.copyWith(
            isLoadingVehicleTypes: false,
            vehicleCatalogFailure: _visibleVehicleCatalogFailure,
          ),
        );
    }
  }

  Future<void> _handleLoadVehicleColors({
    bool preserveExistingFailure = false,
  }) async {
    if (!preserveExistingFailure) {
      _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleColors);
    }
    final visibleFailure = _visibleVehicleCatalogFailure;
    emit(
      state.copyWith(
        isLoadingVehicleColors: true,
        vehicleCatalogFailure: visibleFailure,
        clearVehicleCatalogFailure: visibleFailure == null,
      ),
    );

    final result = await getVehicleColorsUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleColors);
        final remainingFailure = _visibleVehicleCatalogFailure;
        emit(
          state.copyWith(
            vehicleColors: data,
            isLoadingVehicleColors: false,
            vehicleCatalogFailure: remainingFailure,
            clearVehicleCatalogFailure: remainingFailure == null,
          ),
        );
      case ApiErrorResult(:final failure):
        _vehicleCatalogFailures[_VehicleCatalogOperation.vehicleColors] =
            failure;
        emit(
          state.copyWith(
            isLoadingVehicleColors: false,
            vehicleCatalogFailure: _visibleVehicleCatalogFailure,
          ),
        );
    }
  }

  Future<void> _handleSearchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
    bool preserveExistingFailure = false,
  }) async {
    final requestIdentity = ++_vehicleModelRequestIdentity;
    _activeVehicleModelSearch = search;
    _activeVehicleModelType = vehicleType;
    _activeVehicleModelLimit = limit;
    if (!preserveExistingFailure) {
      _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleModels);
    }
    final visibleFailure = _visibleVehicleCatalogFailure;
    emit(
      state.copyWith(
        isSearchingVehicleModels: true,
        vehicleModels: const [],
        vehicleCatalogFailure: visibleFailure,
        clearVehicleCatalogFailure: visibleFailure == null,
      ),
    );

    final result = await searchVehicleModelsUseCase(
      search: search,
      vehicleType: vehicleType,
      limit: limit,
    );
    if (requestIdentity != _vehicleModelRequestIdentity ||
        search != _activeVehicleModelSearch ||
        vehicleType != _activeVehicleModelType ||
        limit != _activeVehicleModelLimit) {
      return;
    }
    switch (result) {
      case ApiSuccessResult(:final data):
        _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleModels);
        final remainingFailure = _visibleVehicleCatalogFailure;
        emit(
          state.copyWith(
            vehicleModels: data,
            isSearchingVehicleModels: false,
            vehicleCatalogFailure: remainingFailure,
            clearVehicleCatalogFailure: remainingFailure == null,
          ),
        );
      case ApiErrorResult(:final failure):
        _vehicleCatalogFailures[_VehicleCatalogOperation.vehicleModels] =
            failure;
        emit(
          state.copyWith(
            isSearchingVehicleModels: false,
            vehicleCatalogFailure: _visibleVehicleCatalogFailure,
          ),
        );
    }
  }

  void _handleVehicleModelQueryChanged({
    required String search,
    String? vehicleType,
  }) {
    _vehicleModelRequestIdentity++;
    _activeVehicleModelSearch = search;
    _activeVehicleModelType = vehicleType;
    _vehicleCatalogFailures.remove(_VehicleCatalogOperation.vehicleModels);
    final remainingFailure = _visibleVehicleCatalogFailure;
    emit(
      state.copyWith(
        vehicleModels: const [],
        isSearchingVehicleModels: false,
        vehicleCatalogFailure: remainingFailure,
        clearVehicleCatalogFailure: remainingFailure == null,
      ),
    );
  }

  void _handleRetryVehicleCatalog() {
    final unresolvedOperations = _vehicleCatalogFailures.keys.toList(
      growable: false,
    );
    for (final operation in unresolvedOperations) {
      switch (operation) {
        case _VehicleCatalogOperation.vehicleTypes:
          _handleLoadVehicleTypes(preserveExistingFailure: true);
        case _VehicleCatalogOperation.vehicleColors:
          _handleLoadVehicleColors(preserveExistingFailure: true);
        case _VehicleCatalogOperation.vehicleModels:
          _handleSearchVehicleModels(
            search: _activeVehicleModelSearch,
            vehicleType: _activeVehicleModelType,
            limit: _activeVehicleModelLimit,
            preserveExistingFailure: true,
          );
      }
    }
  }

  void _handleStepChanged(int step) {
    emit(state.copyWith(currentStep: step));
  }

  void _handlePersonalDataUpdated(RegisterPersonalData personalData) {
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
      password: personalData.password,
      email: personalData.email,
      nationalId: personalData.civilId.isNotEmpty
          ? personalData.civilId
          : state.draft.nationalId,
      nationalIdExpiry: personalData.nationalIdExpiry.isNotEmpty
          ? personalData.nationalIdExpiry
          : state.draft.nationalIdExpiry,
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
          : state.draft.licenseNumber,
      licenseExpiry: vehicleData.licenseExpiry.isNotEmpty
          ? vehicleData.licenseExpiry
          : state.draft.licenseExpiry,
      vehicleLicenseExpiry: vehicleData.vehicleLicenseExpiry.isNotEmpty
          ? vehicleData.vehicleLicenseExpiry
          : state.draft.vehicleLicenseExpiry,
      contractExpiry: vehicleData.contractExpiry,
      clearContractExpiry: vehicleData.contractExpiry == null,
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
