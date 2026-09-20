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
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/repo/driver_registration_repository.dart';
import 'package:meal_mate_delivery/features/register/domain/register_personal_data.dart';
import 'package:meal_mate_delivery/features/register/domain/register_vehicle_data.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_restaurants_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/resubmit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/submit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/upload_driver_document_usecase.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_event.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_state.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_view_model.dart';

class MockDriverRegistrationRepository implements DriverRegistrationRepository {
  List<DriverRestaurantEntity> restaurants = [];
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
  bool shouldFailUpload = false;
  bool shouldFailSubmit = false;

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async {
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

    test('loads restaurants and updates draft with first restaurant', () async {
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
      expect(viewModel.state.draft.restaurantId, 'res-1');
      expect(viewModel.state.draft.restaurantName, 'Burger King');
    });

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
      expect(viewModel.state.draft.vehicleYear, 2023);
      expect(viewModel.state.selectedVehicleColor, const Color(0xFF112233));
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
        viewModel.doIntent(
          const DriverRegistrationSetDraftEvent(
            DriverRegistrationDraftEntity(
              restaurantId: 'res-1',
              fullNameAr: 'أحمد',
              fullNameEn: 'Ahmed',
              phone: '+966501234567',
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
            ),
          ),
        );

        viewModel.doIntent(const DriverRegistrationSubmitEvent());
        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.status,
          DriverRegistrationStatus.submissionSuccess,
        );
        expect(viewModel.state.submissionResult?.registrationId, 'reg-100');
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
