import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/register/data/data_source/driver_registration_remote_data_source.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_registration_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_resubmit_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_file_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_registration_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_restaurant_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/repo/driver_registration_repository_impl.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_file_upload_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_draft_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_restaurant_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/repo/driver_registration_repository.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_restaurants_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/resubmit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/submit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/upload_driver_document_usecase.dart';

class FakeDriverRegistrationRemoteDataSource
    implements DriverRegistrationRemoteDataSource {
  List<DriverRestaurantResponseDto> restaurantsResponse = [];
  DriverFileUploadResponseDto uploadResponse = const DriverFileUploadResponseDto();
  DriverRegistrationResponseDto submitResponse = const DriverRegistrationResponseDto();
  DriverRegistrationResponseDto resubmitResponse = const DriverRegistrationResponseDto();
  Exception? errorToThrow;

  @override
  Future<List<DriverRestaurantResponseDto>> getRestaurants() async {
    if (errorToThrow != null) throw errorToThrow!;
    return restaurantsResponse;
  }

  @override
  Future<DriverFileUploadResponseDto> uploadDocument(File file) async {
    if (errorToThrow != null) throw errorToThrow!;
    return uploadResponse;
  }

  @override
  Future<DriverRegistrationResponseDto> submitRegistration(
    DriverRegistrationRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return submitResponse;
  }

  @override
  Future<DriverRegistrationResponseDto> resubmitRegistration(
    String registrationId,
    DriverResubmitRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resubmitResponse;
  }
}

class FakeDriverRegistrationRepository implements DriverRegistrationRepository {
  List<DriverRestaurantEntity> restaurants = [];
  DriverFileUploadResultEntity uploadResult =
      const DriverFileUploadResultEntity(storageKey: 'fake-key');
  DriverRegistrationResultEntity registrationResult =
      const DriverRegistrationResultEntity(
    registrationId: 'reg-1',
    restaurantId: 'res-1',
    restaurantName: 'Test',
    phone: '+966500000000',
    status: 'Submitted',
    message: 'Success',
  );

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async {
    return ApiSuccessResult(data: restaurants);
  }

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(File file) async {
    return ApiSuccessResult(data: uploadResult);
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async {
    return ApiSuccessResult(data: registrationResult);
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async {
    return ApiSuccessResult(data: registrationResult);
  }
}

void main() {
  group('Driver Registration UseCases Tests', () {
    late FakeDriverRegistrationRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeDriverRegistrationRepository();
    });

    test('GetDriverRestaurantsUseCase returns restaurant entities', () async {
      fakeRepo.restaurants = [
        const DriverRestaurantEntity(
          id: 'res-1',
          tradeName: 'Burger',
          tradeNameAr: 'برجر',
          tradeNameEn: 'Burger',
        ),
      ];

      final useCase = GetDriverRestaurantsUseCase(fakeRepo);
      final result = await useCase();

      expect(result, isA<ApiSuccessResult<List<DriverRestaurantEntity>>>());
      final data = (result as ApiSuccessResult<List<DriverRestaurantEntity>>).data;
      expect(data.first.id, 'res-1');
      expect(data.first.tradeName, 'Burger');
    });

    test('UploadDriverDocumentUseCase returns upload result entity', () async {
      final useCase = UploadDriverDocumentUseCase(fakeRepo);
      final result = await useCase(File('dummy.png'));

      expect(result, isA<ApiSuccessResult<DriverFileUploadResultEntity>>());
      final data = (result as ApiSuccessResult<DriverFileUploadResultEntity>).data;
      expect(data.storageKey, 'fake-key');
    });

    test('SubmitDriverRegistrationUseCase returns registration result entity', () async {
      final useCase = SubmitDriverRegistrationUseCase(fakeRepo);
      final result = await useCase(const DriverRegistrationDraftEntity());

      expect(result, isA<ApiSuccessResult<DriverRegistrationResultEntity>>());
      final data = (result as ApiSuccessResult<DriverRegistrationResultEntity>).data;
      expect(data.registrationId, 'reg-1');
      expect(data.status, 'Submitted');
    });

    test('ResubmitDriverRegistrationUseCase returns registration result entity', () async {
      final useCase = ResubmitDriverRegistrationUseCase(fakeRepo);
      final result = await useCase(
        registrationId: 'reg-1',
        resubmitData: const DriverResubmitEntity(),
      );

      expect(result, isA<ApiSuccessResult<DriverRegistrationResultEntity>>());
      final data = (result as ApiSuccessResult<DriverRegistrationResultEntity>).data;
      expect(data.registrationId, 'reg-1');
    });
  });

  group('DriverRegistrationRepositoryImpl Tests', () {
    late FakeDriverRegistrationRemoteDataSource fakeDataSource;
    late DriverRegistrationRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeDriverRegistrationRemoteDataSource();
      repository = DriverRegistrationRepositoryImpl(fakeDataSource);
    });

    test('getRestaurants maps DTO list to entity list on success', () async {
      fakeDataSource.restaurantsResponse = [
        const DriverRestaurantResponseDto(
          id: 'res-1',
          tradeName: 'Pizza Box',
        ),
      ];

      final result = await repository.getRestaurants();

      expect(result, isA<ApiSuccessResult<List<DriverRestaurantEntity>>>());
      final data = (result as ApiSuccessResult<List<DriverRestaurantEntity>>).data;
      expect(data.length, 1);
      expect(data.first.tradeName, 'Pizza Box');
    });

    test('getRestaurants wraps DioException into ApiErrorResult', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/restaurants'),
        type: DioExceptionType.connectionTimeout,
      );

      final result = await repository.getRestaurants();

      expect(result, isA<ApiErrorResult<List<DriverRestaurantEntity>>>());
      final failure = (result as ApiErrorResult<List<DriverRestaurantEntity>>).failure;
      expect(failure, isNotNull);
    });

    test('uploadDocument maps upload response to entity', () async {
      fakeDataSource.uploadResponse = const DriverFileUploadResponseDto(
        storageKey: 'key-abc',
        fileName: 'id.jpg',
      );

      final result = await repository.uploadDocument(File('id.jpg'));

      expect(result, isA<ApiSuccessResult<DriverFileUploadResultEntity>>());
      final data = (result as ApiSuccessResult<DriverFileUploadResultEntity>).data;
      expect(data.storageKey, 'key-abc');
      expect(data.fileName, 'id.jpg');
    });

    test('submitRegistration maps response to entity', () async {
      fakeDataSource.submitResponse = const DriverRegistrationResponseDto(
        registrationId: 'reg-999',
        restaurantName: 'Balance Box',
        status: 'Submitted',
      );

      final result = await repository.submitRegistration(
        const DriverRegistrationDraftEntity(restaurantId: 'res-1'),
      );

      expect(result, isA<ApiSuccessResult<DriverRegistrationResultEntity>>());
      final data = (result as ApiSuccessResult<DriverRegistrationResultEntity>).data;
      expect(data.registrationId, 'reg-999');
      expect(data.restaurantName, 'Balance Box');
      expect(data.status, 'Submitted');
    });

    test('resubmitRegistration maps response to entity', () async {
      fakeDataSource.resubmitResponse = const DriverRegistrationResponseDto(
        registrationId: 'reg-999',
        status: 'Submitted',
      );

      final result = await repository.resubmitRegistration(
        registrationId: 'reg-999',
        resubmitData: const DriverResubmitEntity(vehicleYear: 2024),
      );

      expect(result, isA<ApiSuccessResult<DriverRegistrationResultEntity>>());
      final data = (result as ApiSuccessResult<DriverRegistrationResultEntity>).data;
      expect(data.registrationId, 'reg-999');
    });
  });
}
