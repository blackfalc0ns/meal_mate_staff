import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/register/data/data_source/driver_registration_remote_data_source.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_registration_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_resubmit_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_file_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_registration_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_restaurant_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_nationality_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_color_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_model_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_type_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/repo/driver_registration_repository_impl.dart';
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

class _MockRemoteDataSource implements DriverRegistrationRemoteDataSource {
  DriverResubmitRequestDto? lastResubmitDto;
  String? lastRegistrationId;
  bool shouldFail = false;

  @override
  Future<List<DriverRestaurantResponseDto>> getRestaurants() async => [];

  @override
  Future<List<DriverNationalityResponseDto>> getNationalities() async => [];

  @override
  Future<List<DriverVehicleTypeResponseDto>> getVehicleTypes() async =>
      const [];

  @override
  Future<List<DriverVehicleColorResponseDto>> getVehicleColors() async =>
      const [];

  @override
  Future<List<DriverVehicleModelResponseDto>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async => const [];

  @override
  Future<DriverFileUploadResponseDto> uploadDocument(File file) async =>
      const DriverFileUploadResponseDto(storageKey: 'key-new');

  @override
  Future<DriverRegistrationResponseDto> submitRegistration(
    DriverRegistrationRequestDto request,
  ) async => const DriverRegistrationResponseDto(registrationId: 'reg-1');

  @override
  Future<DriverRegistrationResponseDto> resubmitRegistration(
    String registrationId,
    DriverResubmitRequestDto request,
  ) async {
    lastRegistrationId = registrationId;
    lastResubmitDto = request;
    if (shouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/resubmit'),
        response: Response(
          requestOptions: RequestOptions(path: '/resubmit'),
          statusCode: 400,
          data: {'message': 'Invalid resubmission data'},
        ),
      );
    }
    return const DriverRegistrationResponseDto(
      registrationId: 'reg-resubmitted-123',
      restaurantId: 'rest-1',
      restaurantName: 'Balance Box',
      phone: '+966501234567',
      status: 'Submitted',
      message: 'Resubmitted successfully',
    );
  }
}

class _MockRepo implements DriverRegistrationRepository {
  bool shouldFail = false;
  String? lastResubmittedId;
  DriverResubmitEntity? lastResubmitData;

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      ApiSuccessResult(data: []);

  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async =>
      ApiSuccessResult(data: []);

  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async =>
      ApiSuccessResult(data: const []);

  @override
  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors() async =>
      ApiSuccessResult(data: const []);

  @override
  Future<ApiResult<List<DriverVehicleModelEntity>>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async => ApiSuccessResult(data: const []);

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(
    File file,
  ) async => ApiSuccessResult(
    data: const DriverFileUploadResultEntity(storageKey: 'key'),
  );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async => ApiSuccessResult(
    data: const DriverRegistrationResultEntity(
      registrationId: 'reg-1',
      restaurantId: 'rest-1',
      restaurantName: 'Balance Box',
      phone: '+966501234567',
      status: 'Submitted',
      message: 'Submitted',
    ),
  );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async {
    lastResubmittedId = registrationId;
    lastResubmitData = resubmitData;
    if (shouldFail) {
      return ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Failed to resubmit application',
          exception: const ApiException(
            errorType: ApiErrorType.unknown,
            message: 'Failed to resubmit application',
          ),
        ),
      );
    }
    return ApiSuccessResult(
      data: DriverRegistrationResultEntity(
        registrationId: registrationId,
        restaurantId: resubmitData.restaurantId ?? '',
        restaurantName: 'Balance Box',
        phone: resubmitData.phone ?? '',
        status: 'Submitted',
        message: 'Resubmission successful',
      ),
    );
  }
}

void main() {
  group('Resubmit Driver Registration Tests', () {
    test(
      'DriverRegistrationDraftEntity converts to DriverResubmitEntity correctly',
      () {
        const draft = DriverRegistrationDraftEntity(
          restaurantId: 'rest-42',
          fullNameAr: 'محمد علي',
          fullNameEn: 'Mohammed Ali',
          phone: '+966501234567',
          nationalId: '1020304050',
          nationalIdExpiry: '2030-01-01',
          nationality: 'Saudi',
          vehicleType: 'Car',
          vehicleModel: 'Camry',
          vehiclePlate: '1234 ABC',
          vehicleYear: 2022,
          nationalIdFrontStorageKey: 'civil_front_key',
          nationalIdBackStorageKey: 'civil_back_key',
          drivingLicenseFrontStorageKey: 'license_front_key',
          drivingLicenseBackStorageKey: 'license_back_key',
          vehicleRegistrationStorageKey: 'veh_reg_key',
        );

        final resubmit = draft.toResubmitEntity();

        expect(resubmit.restaurantId, 'rest-42');
        expect(resubmit.fullNameAr, 'محمد علي');
        expect(resubmit.fullNameEn, 'Mohammed Ali');
        expect(resubmit.phone, '+966501234567');
        expect(resubmit.nationalId, '1020304050');
        expect(resubmit.nationalIdFrontStorageKey, 'civil_front_key');
        expect(resubmit.nationalIdBackStorageKey, 'civil_back_key');
        expect(resubmit.drivingLicenseFrontStorageKey, 'license_front_key');
        expect(resubmit.drivingLicenseBackStorageKey, 'license_back_key');
        expect(resubmit.vehicleRegistrationStorageKey, 'veh_reg_key');
      },
    );

    test(
      'Unchanged uploaded storage keys are retained when modifying another document',
      () {
        var draft = const DriverRegistrationDraftEntity(
          nationalIdFrontStorageKey: 'civil_front_original',
          nationalIdBackStorageKey: 'civil_back_original',
          drivingLicenseFrontStorageKey: 'license_front_original',
          drivingLicenseBackStorageKey: 'license_back_original',
          vehicleRegistrationStorageKey: 'veh_reg_original',
        );

        // Driver re-uploads driving license front only
        draft = draft.copyWith(
          drivingLicenseFrontStorageKey: 'license_front_updated',
        );

        final resubmit = draft.toResubmitEntity();

        // Original unchanged keys are retained
        expect(resubmit.nationalIdFrontStorageKey, 'civil_front_original');
        expect(resubmit.nationalIdBackStorageKey, 'civil_back_original');
        expect(resubmit.drivingLicenseBackStorageKey, 'license_back_original');
        expect(resubmit.vehicleRegistrationStorageKey, 'veh_reg_original');
        // Only modified key is updated
        expect(resubmit.drivingLicenseFrontStorageKey, 'license_front_updated');
      },
    );

    test(
      'Repository calls remoteDataSource.resubmitRegistration and maps response',
      () async {
        final mockDataSource = _MockRemoteDataSource();
        final repository = DriverRegistrationRepositoryImpl(mockDataSource);

        const resubmitData = DriverResubmitEntity(
          restaurantId: 'rest-1',
          fullNameEn: 'John Doe',
          phone: '+966500000000',
          nationalIdFrontStorageKey: 'key-civil',
        );

        final result = await repository.resubmitRegistration(
          registrationId: 'reg-999',
          resubmitData: resubmitData,
        );

        expect(mockDataSource.lastRegistrationId, 'reg-999');
        expect(mockDataSource.lastResubmitDto?.restaurantId, 'rest-1');
        expect(mockDataSource.lastResubmitDto?.fullNameEn, 'John Doe');
        expect(
          mockDataSource.lastResubmitDto?.nationalIdFrontStorageKey,
          'key-civil',
        );

        expect(result, isA<ApiSuccessResult<DriverRegistrationResultEntity>>());
        final entity =
            (result as ApiSuccessResult<DriverRegistrationResultEntity>).data;
        expect(entity.registrationId, 'reg-resubmitted-123');
        expect(entity.status, 'Submitted');
      },
    );

    test('Repository returns ApiErrorResult on DioException', () async {
      final mockDataSource = _MockRemoteDataSource()..shouldFail = true;
      final repository = DriverRegistrationRepositoryImpl(mockDataSource);

      final result = await repository.resubmitRegistration(
        registrationId: 'reg-999',
        resubmitData: const DriverResubmitEntity(),
      );

      expect(result, isA<ApiErrorResult<DriverRegistrationResultEntity>>());
    });

    test(
      'DriverRegistrationViewModel handles DriverRegistrationResubmitEvent success',
      () async {
        final mockRepo = _MockRepo();
        final viewModel = DriverRegistrationViewModel(
          getRestaurantsUseCase: GetDriverRestaurantsUseCase(mockRepo),
          getNationalitiesUseCase: GetDriverNationalitiesUseCase(mockRepo),
          getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(mockRepo),
          getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(mockRepo),
          searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(
            mockRepo,
          ),
          uploadDocumentUseCase: UploadDriverDocumentUseCase(mockRepo),
          submitRegistrationUseCase: SubmitDriverRegistrationUseCase(mockRepo),
          resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
            mockRepo,
          ),
        );

        const resubmitData = DriverResubmitEntity(
          restaurantId: 'rest-1',
          phone: '+966501234567',
        );

        viewModel.doIntent(
          const DriverRegistrationResubmitEvent(
            registrationId: 'reg-abc-123',
            resubmitData: resubmitData,
          ),
        );

        await Future.delayed(Duration.zero);

        expect(mockRepo.lastResubmittedId, 'reg-abc-123');
        expect(mockRepo.lastResubmitData?.phone, '+966501234567');
        expect(
          viewModel.state.status,
          DriverRegistrationStatus.resubmissionSuccess,
        );
        expect(viewModel.state.isSuccess, isTrue);
        expect(viewModel.state.submissionResult?.registrationId, 'reg-abc-123');
      },
    );

    test(
      'DriverRegistrationViewModel handles DriverRegistrationResubmitEvent failure',
      () async {
        final mockRepo = _MockRepo()..shouldFail = true;
        final viewModel = DriverRegistrationViewModel(
          getRestaurantsUseCase: GetDriverRestaurantsUseCase(mockRepo),
          getNationalitiesUseCase: GetDriverNationalitiesUseCase(mockRepo),
          getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(mockRepo),
          getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(mockRepo),
          searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(
            mockRepo,
          ),
          uploadDocumentUseCase: UploadDriverDocumentUseCase(mockRepo),
          submitRegistrationUseCase: SubmitDriverRegistrationUseCase(mockRepo),
          resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
            mockRepo,
          ),
        );

        viewModel.doIntent(
          const DriverRegistrationResubmitEvent(
            registrationId: 'reg-fail',
            resubmitData: DriverResubmitEntity(),
          ),
        );

        await Future.delayed(Duration.zero);

        expect(viewModel.state.status, DriverRegistrationStatus.error);
        expect(viewModel.state.errorMessage, 'Failed to resubmit application');
      },
    );
  });
}
