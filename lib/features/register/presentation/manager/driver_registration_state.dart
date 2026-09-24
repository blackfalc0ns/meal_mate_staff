import 'dart:ui';

import '../../../../core/constants/assets.dart';
import '../../../../core/network/failures.dart';
import '../../domain/entities/driver_registration_draft_entity.dart';
import '../../domain/entities/driver_registration_result_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../../domain/entities/driver_vehicle_color_entity.dart';
import '../../domain/entities/driver_vehicle_model_entity.dart';
import '../../domain/entities/driver_vehicle_type_entity.dart';
import '../../domain/register_document.dart';

enum DriverRegistrationStatus {
  initial,
  loadingRestaurants,
  restaurantsLoaded,
  loadingNationalities,
  nationalitiesLoaded,
  loadingVehicleTypes,
  vehicleTypesLoaded,
  loadingVehicleColors,
  vehicleColorsLoaded,
  searchingVehicleModels,
  vehicleModelsLoaded,
  uploadingDocument,
  documentUploaded,
  submitting,
  submissionSuccess,
  resubmitting,
  resubmissionSuccess,
  error,
}

class DriverRegistrationState {
  const DriverRegistrationState({
    this.status = DriverRegistrationStatus.initial,
    this.currentStep = 1,
    this.draft = const DriverRegistrationDraftEntity(),
    this.restaurants = const [],
    this.nationalities = const [],
    this.vehicleTypes = const [],
    this.vehicleColors = const [],
    this.vehicleModels = const [],
    this.isLoadingRestaurants = false,
    this.isLoadingNationalities = false,
    this.isLoadingVehicleTypes = false,
    this.isLoadingVehicleColors = false,
    this.isSearchingVehicleModels = false,
    this.vehicleCatalogFailure,
    this.documents = const [
      RegisterDocument(
        id: 'civil-card',
        imageAsset: AppAssets.registrationLicenseSample,
      ),
      RegisterDocument(
        id: 'driving-license',
        imageAsset: AppAssets.registrationLicenseSample,
      ),
      RegisterDocument(
        id: 'car-registration',
        imageAsset: AppAssets.registrationLicenseSample,
      ),
      RegisterDocument(
        id: 'vehicle-photo',
        imageAsset: AppAssets.registrationVehicleSample,
      ),
      RegisterDocument(
        id: 'personal-photo',
        imageAsset: AppAssets.registrationDriverRole,
      ),
    ],
    this.selectedVehicleColor = const Color(0xFF603BC1),
    this.ownsVehicle = true,
    this.submissionResult,
    this.failure,
    this.errorMessage,
    this.uploadingDocumentId,
  });

  final DriverRegistrationStatus status;
  final int currentStep;
  final DriverRegistrationDraftEntity draft;
  final List<DriverRestaurantEntity> restaurants;
  final List<DriverNationalityEntity> nationalities;
  final List<DriverVehicleTypeEntity> vehicleTypes;
  final List<DriverVehicleColorEntity> vehicleColors;
  final List<DriverVehicleModelEntity> vehicleModels;
  final bool isLoadingRestaurants;
  final bool isLoadingNationalities;
  final bool isLoadingVehicleTypes;
  final bool isLoadingVehicleColors;
  final bool isSearchingVehicleModels;
  final Failure? vehicleCatalogFailure;
  final List<RegisterDocument> documents;
  final Color selectedVehicleColor;
  final bool ownsVehicle;
  final DriverRegistrationResultEntity? submissionResult;
  final Failure? failure;
  final String? errorMessage;
  final String? uploadingDocumentId;

  bool get isSubmitting =>
      status == DriverRegistrationStatus.submitting ||
      status == DriverRegistrationStatus.resubmitting;
  bool get isSuccess =>
      status == DriverRegistrationStatus.submissionSuccess ||
      status == DriverRegistrationStatus.resubmissionSuccess;

  Map<String, String> get selectedImagePaths {
    final map = <String, String>{};
    for (final doc in documents) {
      if (doc.localFilePath != null && doc.localFilePath!.isNotEmpty) {
        map[doc.id] = doc.localFilePath!;
      }
    }
    return map;
  }

  RegisterDocument? getDocument(String id) {
    try {
      return documents.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  DriverRegistrationState copyWith({
    DriverRegistrationStatus? status,
    int? currentStep,
    DriverRegistrationDraftEntity? draft,
    List<DriverRestaurantEntity>? restaurants,
    List<DriverNationalityEntity>? nationalities,
    List<DriverVehicleTypeEntity>? vehicleTypes,
    List<DriverVehicleColorEntity>? vehicleColors,
    List<DriverVehicleModelEntity>? vehicleModels,
    bool? isLoadingRestaurants,
    bool? isLoadingNationalities,
    bool? isLoadingVehicleTypes,
    bool? isLoadingVehicleColors,
    bool? isSearchingVehicleModels,
    Failure? vehicleCatalogFailure,
    List<RegisterDocument>? documents,
    Color? selectedVehicleColor,
    bool? ownsVehicle,
    DriverRegistrationResultEntity? submissionResult,
    Failure? failure,
    String? errorMessage,
    String? uploadingDocumentId,
    bool clearUploading = false,
    bool clearVehicleCatalogFailure = false,
  }) {
    return DriverRegistrationState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      draft: draft ?? this.draft,
      restaurants: restaurants ?? this.restaurants,
      nationalities: nationalities ?? this.nationalities,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      vehicleColors: vehicleColors ?? this.vehicleColors,
      vehicleModels: vehicleModels ?? this.vehicleModels,
      isLoadingRestaurants: isLoadingRestaurants ?? this.isLoadingRestaurants,
      isLoadingNationalities:
          isLoadingNationalities ?? this.isLoadingNationalities,
      isLoadingVehicleTypes:
          isLoadingVehicleTypes ?? this.isLoadingVehicleTypes,
      isLoadingVehicleColors:
          isLoadingVehicleColors ?? this.isLoadingVehicleColors,
      isSearchingVehicleModels:
          isSearchingVehicleModels ?? this.isSearchingVehicleModels,
      vehicleCatalogFailure: clearVehicleCatalogFailure
          ? null
          : (vehicleCatalogFailure ?? this.vehicleCatalogFailure),
      documents: documents ?? this.documents,
      selectedVehicleColor: selectedVehicleColor ?? this.selectedVehicleColor,
      ownsVehicle: ownsVehicle ?? this.ownsVehicle,
      submissionResult: submissionResult ?? this.submissionResult,
      failure: failure ?? this.failure,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadingDocumentId: clearUploading
          ? null
          : (uploadingDocumentId ?? this.uploadingDocumentId),
    );
  }
}
