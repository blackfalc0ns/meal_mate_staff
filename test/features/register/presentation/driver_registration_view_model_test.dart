import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_file_upload_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_draft_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_restaurant_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_nationality_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_color_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_model_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_type_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/repo/driver_registration_repository.dart';
import 'package:meal_mate_delivery/features/register/domain/register_personal_data.dart';
import 'package:meal_mate_delivery/features/register/domain/register_vehicle_data.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_restaurants_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_nationalities_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_colors_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_types_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/resubmit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/search_driver_vehicle_models_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/submit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/upload_driver_document_usecase.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_event.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_state.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_view_model.dart';

class MockDriverRegistrationRepository implements DriverRegistrationRepository {
  List<DriverNationalityEntity> nationalities = [];
  List<DriverRestaurantEntity> restaurants = [];
  List<DriverVehicleTypeEntity> vehicleTypes = [];
  List<DriverVehicleColorEntity> vehicleColors = [];
  List<DriverVehicleModelEntity> vehicleModels = [];
  DriverFileUploadResultEntity uploadResult =
      const DriverFileUploadResultEntity(
        storageKey: 'https://ik.imagekit.io/doc.png',
      );
  DriverRegistrationResultEntity submitResult =
      const DriverRegistrationResultEntity(
        registrationId: 'reg-100',
        restaurantId: 'res-1',
        restaurantName: 'Balance Box',
        phone: '+966501234567',
        status: 'Submitted',
        message: 'Application submitted successfully',
      );

  bool shouldFailRestaurants = false;
  bool shouldFailVehicleTypes = false;
  bool shouldFailVehicleColors = false;
  bool shouldFailVehicleModels = false;
  bool shouldFailUpload = false;
  bool shouldFailSubmit = false;
  String? lastModelSearch;
  String? lastModelVehicleType;
  int? lastModelLimit;
  int vehicleTypeCallCount = 0;
  int vehicleColorCallCount = 0;
  int vehicleModelCallCount = 0;
  DriverRegistrationDraftEntity? lastSubmittedDraft;
  Completer<ApiResult<List<DriverRestaurantEntity>>>? restaurantsCompleter;
  Completer<ApiResult<List<DriverNationalityEntity>>>? nationalitiesCompleter;
  Completer<ApiResult<List<DriverVehicleTypeEntity>>>? vehicleTypesCompleter;
  Completer<ApiResult<List<DriverVehicleColorEntity>>>? vehicleColorsCompleter;
  final Map<String?, Completer<ApiResult<List<DriverVehicleModelEntity>>>>
  vehicleModelCompleters = {};

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async {
    if (restaurantsCompleter != null) {
      return restaurantsCompleter!.future;
    }
    if (shouldFailRestaurants) {
      return ApiErrorResult(
        failure: ServerFailure.fromDioError(
          dioException: DioException(
            requestOptions: RequestOptions(path: '/restaurants'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );
    }
    return ApiSuccessResult(data: restaurants);
  }

  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async {
    if (nationalitiesCompleter != null) {
      return nationalitiesCompleter!.future;
    }
    return ApiSuccessResult(data: nationalities);
  }

  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async {
    vehicleTypeCallCount++;
    if (vehicleTypesCompleter != null) {
      return vehicleTypesCompleter!.future;
    }
    if (shouldFailVehicleTypes) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Vehicle catalog failure'),
      );
    }
    return ApiSuccessResult(data: vehicleTypes);
  }

  @override
  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors() async {
    vehicleColorCallCount++;
    if (vehicleColorsCompleter != null) {
      return vehicleColorsCompleter!.future;
    }
    if (shouldFailVehicleColors) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Vehicle catalog failure'),
      );
    }
    return ApiSuccessResult(data: vehicleColors);
  }

  @override
  Future<ApiResult<List<DriverVehicleModelEntity>>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async {
    vehicleModelCallCount++;
    lastModelSearch = search;
    lastModelVehicleType = vehicleType;
    lastModelLimit = limit;
    final completer = vehicleModelCompleters[search];
    if (completer != null) return completer.future;
    if (shouldFailVehicleModels) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Vehicle catalog failure'),
      );
    }
    return ApiSuccessResult(data: vehicleModels);
  }

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(
    File file,
  ) async {
    if (shouldFailUpload) {
      return ApiErrorResult(
        failure: ServerFailure.fromDioError(
          dioException: DioException(
            requestOptions: RequestOptions(path: '/upload'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );
    }
    return ApiSuccessResult(data: uploadResult);
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async {
    lastSubmittedDraft = draft;
    if (shouldFailSubmit) {
      return ApiErrorResult(
        failure: ServerFailure.fromDioError(
          dioException: DioException(
            requestOptions: RequestOptions(path: '/register'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );
    }
    return ApiSuccessResult(data: submitResult);
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async {
    return ApiSuccessResult(data: submitResult);
  }
}

void main() {
  group('DriverRegistrationViewModel Tests', () {
    late MockDriverRegistrationRepository mockRepo;
    late DriverRegistrationViewModel viewModel;

    setUp(() {
      mockRepo = MockDriverRegistrationRepository();
      viewModel = DriverRegistrationViewModel(
        getRestaurantsUseCase: GetDriverRestaurantsUseCase(mockRepo),
        getNationalitiesUseCase: GetDriverNationalitiesUseCase(mockRepo),
        getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(mockRepo),
        getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(mockRepo),
        searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(mockRepo),
        uploadDocumentUseCase: UploadDriverDocumentUseCase(mockRepo),
        submitRegistrationUseCase: SubmitDriverRegistrationUseCase(mockRepo),
        resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
          mockRepo,
        ),
      );
    });

    tearDown(() {
      viewModel.close();
    });

    test('initial state is set up with 5 default documents and step 1', () {
      expect(viewModel.state.status, DriverRegistrationStatus.initial);
      expect(viewModel.state.currentStep, 1);
      expect(viewModel.state.documents.length, 5);
      expect(viewModel.state.documents.first.id, 'civil-card');
      expect(viewModel.state.ownsVehicle, isTrue);
    });

    test(
      'loads restaurants without silently selecting the first one',
      () async {
        mockRepo.restaurants = [
          const DriverRestaurantEntity(
            id: 'res-1',
            tradeName: 'Burger King',
            tradeNameAr: 'برجر كنج',
            tradeNameEn: 'Burger King',
          ),
        ];

        viewModel.doIntent(const DriverRegistrationLoadRestaurantsEvent());
        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.status,
          DriverRegistrationStatus.restaurantsLoaded,
        );
        expect(viewModel.state.restaurants.length, 1);
        expect(viewModel.state.draft.restaurantId, isEmpty);
        expect(viewModel.state.draft.restaurantName, isEmpty);
      },
    );

    test('loads nationalities into state', () async {
      mockRepo.nationalities = const [
        DriverNationalityEntity(
          code: 'KW',
          name: 'Kuwaiti',
          nameAr: 'كويتي',
          nameEn: 'Kuwaiti',
          countryName: 'Kuwait',
          countryNameAr: 'الكويت',
          countryNameEn: 'Kuwait',
          flagEmoji: '🇰🇼',
        ),
      ];

      viewModel.doIntent(const DriverRegistrationLoadNationalitiesEvent());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.nationalities.single.code, 'KW');
      expect(
        viewModel.state.status,
        DriverRegistrationStatus.nationalitiesLoaded,
      );
    });

    test('loads vehicle types into catalog state', () async {
      mockRepo.vehicleTypes = const [
        DriverVehicleTypeEntity(
          code: 'sedan',
          nameAr: 'سيدان',
          nameEn: 'Sedan',
          iconKey: 'car',
        ),
      ];

      viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.vehicleTypes.single.code, 'sedan');
      expect(viewModel.state.isLoadingVehicleTypes, isFalse);
    });

    test('loads vehicle colors into catalog state', () async {
      mockRepo.vehicleColors = const [
        DriverVehicleColorEntity(
          hex: '#112233',
          nameAr: 'كحلي',
          nameEn: 'Navy',
          isDefault: false,
          displayOrder: 1,
        ),
      ];

      viewModel.doIntent(const DriverRegistrationLoadVehicleColorsEvent());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.vehicleColors.single.hex, '#112233');
      expect(viewModel.state.isLoadingVehicleColors, isFalse);
    });

    test('searches vehicle models with the supplied parameters', () async {
      mockRepo.vehicleModels = const [
        DriverVehicleModelEntity(
          value: 'toyota-camry',
          makeCode: 'toyota',
          makeNameAr: 'تويوتا',
          makeNameEn: 'Toyota',
          modelCode: 'camry',
          modelNameAr: 'كامري',
          modelNameEn: 'Camry',
          fullNameAr: 'تويوتا كامري',
          fullNameEn: 'Toyota Camry',
          vehicleType: 'sedan',
        ),
      ];

      viewModel.doIntent(
        const DriverRegistrationSearchVehicleModelsEvent(
          search: 'cam',
          vehicleType: 'sedan',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(mockRepo.lastModelSearch, 'cam');
      expect(mockRepo.lastModelVehicleType, 'sedan');
      expect(mockRepo.lastModelLimit, 40);
      expect(viewModel.state.vehicleModels.single.value, 'toyota-camry');
    });

    test(
      'older model response finishing last cannot replace latest results',
      () async {
        final older = Completer<ApiResult<List<DriverVehicleModelEntity>>>();
        final latest = Completer<ApiResult<List<DriverVehicleModelEntity>>>();
        mockRepo.vehicleModelCompleters
          ..['T'] = older
          ..['To'] = latest;

        viewModel.doIntent(
          const DriverRegistrationSearchVehicleModelsEvent(
            search: 'T',
            vehicleType: 'Car',
          ),
        );
        viewModel.doIntent(
          const DriverRegistrationSearchVehicleModelsEvent(
            search: 'To',
            vehicleType: 'Car',
          ),
        );

        latest.complete(
          ApiSuccessResult(
            data: const [
              DriverVehicleModelEntity(
                value: 'LATEST',
                makeCode: 'TOYOTA',
                makeNameAr: 'تويوتا',
                makeNameEn: 'Toyota',
                modelCode: 'CAMRY',
                modelNameAr: 'كامري',
                modelNameEn: 'Camry',
                fullNameAr: 'تويوتا كامري',
                fullNameEn: 'Toyota Camry',
                vehicleType: 'Car',
              ),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(viewModel.state.vehicleModels.single.value, 'LATEST');

        older.complete(
          ApiSuccessResult(
            data: const [
              DriverVehicleModelEntity(
                value: 'STALE',
                makeCode: 'OLD',
                makeNameAr: 'قديم',
                makeNameEn: 'Old',
                modelCode: 'OLD',
                modelNameAr: 'قديم',
                modelNameEn: 'Old',
                fullNameAr: 'نتيجة قديمة',
                fullNameEn: 'Stale result',
                vehicleType: 'Car',
              ),
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.state.vehicleModels.single.value, 'LATEST');
      },
    );

    test('query change invalidates an in-flight model response', () async {
      final older = Completer<ApiResult<List<DriverVehicleModelEntity>>>();
      mockRepo.vehicleModelCompleters['Cam'] = older;

      viewModel.doIntent(
        const DriverRegistrationSearchVehicleModelsEvent(
          search: 'Cam',
          vehicleType: 'Car',
        ),
      );
      viewModel.doIntent(
        const DriverRegistrationVehicleModelQueryChangedEvent(
          search: 'Bike',
          vehicleType: 'Bicycle',
        ),
      );

      older.complete(
        ApiSuccessResult(
          data: const [
            DriverVehicleModelEntity(
              value: 'STALE',
              makeCode: 'TOYOTA',
              makeNameAr: 'تويوتا',
              makeNameEn: 'Toyota',
              modelCode: 'CAMRY',
              modelNameAr: 'كامري',
              modelNameEn: 'Camry',
              fullNameAr: 'تويوتا كامري',
              fullNameEn: 'Toyota Camry',
              vehicleType: 'Car',
            ),
          ],
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.vehicleModels, isEmpty);
      expect(viewModel.state.isSearchingVehicleModels, isFalse);
    });

    test('retry routes a vehicle type failure only to vehicle types', () async {
      mockRepo.shouldFailVehicleTypes = true;
      viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
      await Future<void>.delayed(Duration.zero);
      mockRepo.shouldFailVehicleTypes = false;

      viewModel.doIntent(const DriverRegistrationRetryVehicleCatalogEvent());
      await Future<void>.delayed(Duration.zero);

      expect(mockRepo.vehicleTypeCallCount, 2);
      expect(mockRepo.vehicleColorCallCount, 0);
      expect(mockRepo.vehicleModelCallCount, 0);
    });

    test(
      'retry routes a vehicle color failure only to vehicle colors',
      () async {
        mockRepo.shouldFailVehicleColors = true;
        viewModel.doIntent(const DriverRegistrationLoadVehicleColorsEvent());
        await Future<void>.delayed(Duration.zero);
        mockRepo.shouldFailVehicleColors = false;

        viewModel.doIntent(const DriverRegistrationRetryVehicleCatalogEvent());
        await Future<void>.delayed(Duration.zero);

        expect(mockRepo.vehicleTypeCallCount, 0);
        expect(mockRepo.vehicleColorCallCount, 2);
        expect(mockRepo.vehicleModelCallCount, 0);
      },
    );

    test(
      'retry preserves and reroutes simultaneous type and color failures',
      () async {
        mockRepo
          ..shouldFailVehicleTypes = true
          ..shouldFailVehicleColors = true;
        viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
        viewModel.doIntent(const DriverRegistrationLoadVehicleColorsEvent());
        await Future<void>.delayed(Duration.zero);

        expect(mockRepo.vehicleTypeCallCount, 1);
        expect(mockRepo.vehicleColorCallCount, 1);
        expect(viewModel.state.vehicleCatalogFailure, isNotNull);

        mockRepo.shouldFailVehicleTypes = false;
        viewModel.doIntent(const DriverRegistrationRetryVehicleCatalogEvent());
        await Future<void>.delayed(Duration.zero);

        expect(mockRepo.vehicleTypeCallCount, 2);
        expect(mockRepo.vehicleColorCallCount, 2);
        expect(viewModel.state.vehicleCatalogFailure, isNotNull);

        mockRepo.shouldFailVehicleColors = false;
        viewModel.doIntent(const DriverRegistrationRetryVehicleCatalogEvent());
        await Future<void>.delayed(Duration.zero);

        expect(mockRepo.vehicleTypeCallCount, 2);
        expect(mockRepo.vehicleColorCallCount, 3);
        expect(viewModel.state.vehicleCatalogFailure, isNull);
      },
    );

    test('retry repeats the exact failed model search parameters', () async {
      mockRepo.shouldFailVehicleModels = true;
      viewModel.doIntent(
        const DriverRegistrationSearchVehicleModelsEvent(
          search: ' Cam ',
          vehicleType: 'Car',
          limit: 17,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      mockRepo.shouldFailVehicleModels = false;

      viewModel.doIntent(const DriverRegistrationRetryVehicleCatalogEvent());
      await Future<void>.delayed(Duration.zero);

      expect(mockRepo.vehicleModelCallCount, 2);
      expect(mockRepo.lastModelSearch, ' Cam ');
      expect(mockRepo.lastModelVehicleType, 'Car');
      expect(mockRepo.lastModelLimit, 17);
      expect(mockRepo.vehicleTypeCallCount, 0);
      expect(mockRepo.vehicleColorCallCount, 0);
    });

    test('catalog failure preserves the existing registration draft', () async {
      const draft = DriverRegistrationDraftEntity(
        fullNameEn: 'Ahmed Al-Sayed',
        vehicleModel: 'Existing model',
      );
      mockRepo.shouldFailVehicleTypes = true;
      viewModel.doIntent(const DriverRegistrationSetDraftEvent(draft));

      viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
      await Future<void>.delayed(Duration.zero);

      expect(
        viewModel.state.vehicleCatalogFailure?.errorMessage,
        'Vehicle catalog failure',
      );
      expect(viewModel.state.draft.fullNameEn, 'Ahmed Al-Sayed');
      expect(viewModel.state.draft.vehicleModel, 'Existing model');
    });

    test(
      'keeps a vehicle catalog failure after later form catalog loads',
      () async {
        final vehicleTypesCompleter =
            Completer<ApiResult<List<DriverVehicleTypeEntity>>>();
        final restaurantsCompleter =
            Completer<ApiResult<List<DriverRestaurantEntity>>>();
        final nationalitiesCompleter =
            Completer<ApiResult<List<DriverNationalityEntity>>>();
        mockRepo
          ..vehicleTypesCompleter = vehicleTypesCompleter
          ..restaurantsCompleter = restaurantsCompleter
          ..nationalitiesCompleter = nationalitiesCompleter;

        viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
        viewModel.doIntent(const DriverRegistrationLoadRestaurantsEvent());
        viewModel.doIntent(const DriverRegistrationLoadNationalitiesEvent());

        vehicleTypesCompleter.complete(
          ApiErrorResult(
            failure: Failure(errorMessage: 'Vehicle types failed'),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        restaurantsCompleter.complete(ApiSuccessResult(data: const []));
        nationalitiesCompleter.complete(ApiSuccessResult(data: const []));
        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.vehicleCatalogFailure?.errorMessage,
          'Vehicle types failed',
        );
        expect(viewModel.state.failure, isNull);
        expect(
          viewModel.state.status,
          DriverRegistrationStatus.nationalitiesLoaded,
        );
      },
    );

    test('represents vehicle type and color loading independently', () async {
      final vehicleTypesCompleter =
          Completer<ApiResult<List<DriverVehicleTypeEntity>>>();
      final vehicleColorsCompleter =
          Completer<ApiResult<List<DriverVehicleColorEntity>>>();
      mockRepo
        ..vehicleTypesCompleter = vehicleTypesCompleter
        ..vehicleColorsCompleter = vehicleColorsCompleter;

      viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
      viewModel.doIntent(const DriverRegistrationLoadVehicleColorsEvent());

      expect(viewModel.state.isLoadingVehicleTypes, isTrue);
      expect(viewModel.state.isLoadingVehicleColors, isTrue);

      vehicleTypesCompleter.complete(ApiSuccessResult(data: const []));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isLoadingVehicleTypes, isFalse);
      expect(viewModel.state.isLoadingVehicleColors, isTrue);

      vehicleColorsCompleter.complete(ApiSuccessResult(data: const []));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isLoadingVehicleColors, isFalse);
    });

    test(
      'clears stale vehicle catalog failure when a catalog retry starts',
      () async {
        mockRepo.shouldFailVehicleTypes = true;
        viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
        await Future<void>.delayed(Duration.zero);

        final retryCompleter =
            Completer<ApiResult<List<DriverVehicleTypeEntity>>>();
        mockRepo
          ..shouldFailVehicleTypes = false
          ..vehicleTypesCompleter = retryCompleter;
        viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());

        expect(viewModel.state.vehicleCatalogFailure, isNull);
        expect(viewModel.state.isLoadingVehicleTypes, isTrue);

        retryCompleter.complete(ApiSuccessResult(data: const []));
        await Future<void>.delayed(Duration.zero);
      },
    );

    test('step change updates currentStep in state', () {
      viewModel.doIntent(const DriverRegistrationStepChangedEvent(2));
      expect(viewModel.state.currentStep, 2);

      viewModel.doIntent(const DriverRegistrationStepChangedEvent(3));
      expect(viewModel.state.currentStep, 3);
    });

    test('updates personal data and vehicle data into draft', () {
      const personalData = RegisterPersonalData(
        firstName: 'Ahmed',
        lastName: 'Mohamed',
        phone: '+966501234567',
        password: 'Password123!',
        email: 'ahmed@test.com',
        birthDate: '1994/05/20',
        nationality: 'Saudi',
        civilId: '1098765432',
        restaurantId: 'res-1',
        restaurantName: 'Balance Box',
      );

      viewModel.doIntent(
        const DriverRegistrationPersonalDataUpdatedEvent(personalData),
      );

      expect(viewModel.state.draft.fullNameAr, 'Ahmed Mohamed');
      expect(viewModel.state.draft.fullNameEn, 'Ahmed Mohamed');
      expect(viewModel.state.draft.phone, '+966501234567');
      expect(viewModel.state.draft.password, 'Password123!');
      expect(viewModel.state.draft.nationalId, '1098765432');

      const vehicleData = RegisterVehicleData(
        type: 'Car',
        model: 'Toyota Camry',
        manufactureYear: '2023',
        plateNumber: 'ABC 1234',
        country: 'Kuwait',
        color: 'Silver',
        isOwned: true,
      );

      viewModel.doIntent(
        const DriverRegistrationVehicleDataUpdatedEvent(
          vehicleData: vehicleData,
          selectedColor: Color(0xFF112233),
          ownsVehicle: true,
        ),
      );

      expect(viewModel.state.draft.vehicleModel, 'Toyota Camry');
      expect(viewModel.state.draft.vehiclePlate, 'ABC 1234');
      expect(viewModel.state.draft.licenseNumber, isEmpty);
      expect(viewModel.state.draft.vehicleYear, 2023);
      expect(viewModel.state.selectedVehicleColor, const Color(0xFF112233));
    });

    test('does not fabricate missing expiry values before submit', () async {
      viewModel.doIntent(
        const DriverRegistrationSetDraftEvent(
          DriverRegistrationDraftEntity(
            nationalIdExpiry: '',
            licenseExpiry: '',
            vehicleLicenseExpiry: '',
          ),
        ),
      );

      viewModel.doIntent(const DriverRegistrationSubmitEvent());
      await Future<void>.delayed(Duration.zero);

      expect(mockRepo.lastSubmittedDraft?.nationalIdExpiry, isEmpty);
      expect(mockRepo.lastSubmittedDraft?.licenseExpiry, isEmpty);
      expect(mockRepo.lastSubmittedDraft?.vehicleLicenseExpiry, isEmpty);
    });

    test('vehicle update keeps required expiry values empty when omitted', () {
      viewModel.doIntent(
        const DriverRegistrationVehicleDataUpdatedEvent(
          vehicleData: RegisterVehicleData(
            type: 'Car',
            model: 'Camry',
            manufactureYear: '2026',
            plateNumber: 'ABC 123',
            country: 'Kuwait',
            color: '#112233',
            isOwned: true,
            licenseNumber: 'DL-1',
          ),
        ),
      );

      expect(viewModel.state.draft.licenseExpiry, isEmpty);
      expect(viewModel.state.draft.vehicleLicenseExpiry, isEmpty);
    });

    test('blank optional contract expiry is stored as null', () {
      viewModel.doIntent(
        const DriverRegistrationSetDraftEvent(
          DriverRegistrationDraftEntity(
            contractExpiry: '2099-01-04T00:00:00.000',
          ),
        ),
      );

      viewModel.doIntent(
        const DriverRegistrationVehicleDataUpdatedEvent(
          vehicleData: RegisterVehicleData(
            type: 'Car',
            model: 'Camry',
            manufactureYear: '2026',
            plateNumber: 'ABC 123',
            country: 'Kuwait',
            color: '#112233',
            isOwned: true,
            licenseNumber: 'DL-1',
            licenseExpiry: '2099-01-02T00:00:00.000',
            vehicleLicenseExpiry: '2099-01-03T00:00:00.000',
          ),
        ),
      );

      expect(viewModel.state.draft.contractExpiry, isNull);
    });

    test(
      'uploads document, tracks progress, and sets storage keys in draft',
      () async {
        viewModel.doIntent(
          DriverRegistrationUploadDocumentEvent(
            documentId: 'civil-card',
            file: File('civil_card.png'),
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.status,
          DriverRegistrationStatus.documentUploaded,
        );
        final civilDoc = viewModel.state.getDocument('civil-card');
        expect(civilDoc?.isUploaded, isTrue);
        expect(civilDoc?.storageKey, 'https://ik.imagekit.io/doc.png');
        expect(
          viewModel.state.draft.nationalIdFrontStorageKey,
          'https://ik.imagekit.io/doc.png',
        );
        expect(
          viewModel.state.draft.nationalIdBackStorageKey,
          'https://ik.imagekit.io/doc.png',
        );
      },
    );

    test('handles upload document failure', () async {
      mockRepo.shouldFailUpload = true;

      viewModel.doIntent(
        DriverRegistrationUploadDocumentEvent(
          documentId: 'driving-license',
          file: File('license.png'),
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, DriverRegistrationStatus.error);
      final doc = viewModel.state.getDocument('driving-license');
      expect(doc?.isUploaded, isFalse);
      expect(doc?.errorMessage, isNotNull);
    });

    test('removes document and clears corresponding draft storageKey', () {
      viewModel.doIntent(
        const DriverRegistrationSetDraftEvent(
          DriverRegistrationDraftEntity(
            nationalIdFrontStorageKey: 'key-1',
            nationalIdBackStorageKey: 'key-2',
          ),
        ),
      );

      viewModel.doIntent(
        const DriverRegistrationRemoveDocumentEvent('civil-card'),
      );

      expect(viewModel.state.draft.nationalIdFrontStorageKey, '');
      expect(viewModel.state.draft.nationalIdBackStorageKey, '');
    });

    test(
      'submits registration successfully and emits submissionSuccess',
      () async {
        const draftWithoutPassword = DriverRegistrationDraftEntity(
          restaurantId: 'res-1',
          fullNameAr: 'أحمد',
          fullNameEn: 'Ahmed',
          phone: '+966501234567',
          password: '',
          nationalId: '1234567890',
          nationalIdExpiry: '2029-01-01T00:00:00Z',
          nationality: 'Saudi',
          vehicleType: 'Car',
          vehicleModel: 'Camry',
          vehiclePlate: 'ABC 1234',
          vehicleYear: 2023,
          licenseNumber: 'LIC-1',
          licenseExpiry: '2029-01-01T00:00:00Z',
          vehicleLicenseExpiry: '2029-01-01T00:00:00Z',
          nationalIdFrontStorageKey: 'nid-f',
          nationalIdBackStorageKey: 'nid-b',
          drivingLicenseFrontStorageKey: 'lic-f',
          drivingLicenseBackStorageKey: 'lic-b',
          vehicleRegistrationStorageKey: 'veh-r',
        );
        expect(draftWithoutPassword.isReadyForSubmission, isFalse);

        final readyDraft = draftWithoutPassword.copyWith(
          password: 'Password123!',
        );
        expect(readyDraft.isReadyForSubmission, isTrue);

        viewModel.doIntent(DriverRegistrationSetDraftEvent(readyDraft));

        viewModel.doIntent(const DriverRegistrationSubmitEvent());
        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.status,
          DriverRegistrationStatus.submissionSuccess,
        );
        expect(viewModel.state.submissionResult?.registrationId, 'reg-100');
        expect(mockRepo.lastSubmittedDraft?.password, 'Password123!');
      },
    );

    test(
      'submits registration failure emits error and preserves draft',
      () async {
        mockRepo.shouldFailSubmit = true;

        viewModel.doIntent(const DriverRegistrationSubmitEvent());
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.state.status, DriverRegistrationStatus.error);
        expect(viewModel.state.failure, isNotNull);
      },
    );
  });
}
