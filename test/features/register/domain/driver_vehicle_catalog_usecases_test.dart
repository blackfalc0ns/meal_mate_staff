import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_file_upload_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_nationality_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_draft_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_restaurant_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_color_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_model_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_type_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/repo/driver_registration_repository.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_colors_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_types_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/search_driver_vehicle_models_usecase.dart';

class _FakeDriverRegistrationRepository
    implements DriverRegistrationRepository {
  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      ApiSuccessResult(data: const []);

  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async =>
      ApiSuccessResult(data: const []);

  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async =>
      ApiSuccessResult(
        data: const [
          DriverVehicleTypeEntity(
            code: 'Car',
            nameAr: 'سيارة',
            nameEn: 'Car',
            iconKey: 'car',
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors() async =>
      ApiSuccessResult(
        data: const [
          DriverVehicleColorEntity(
            hex: '#000000',
            nameAr: 'أسود',
            nameEn: 'Black',
            isDefault: true,
            displayOrder: 1,
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverVehicleModelEntity>>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async => ApiSuccessResult(
    data: [
      DriverVehicleModelEntity(
        value: '$search/$vehicleType/$limit',
        makeCode: '',
        makeNameAr: '',
        makeNameEn: '',
        modelCode: '',
        modelNameAr: '',
        modelNameEn: '',
        fullNameAr: '',
        fullNameEn: '',
        vehicleType: vehicleType ?? '',
      ),
    ],
  );

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(
    File file,
  ) async => ApiSuccessResult(
    data: const DriverFileUploadResultEntity(storageKey: ''),
  );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async => ApiSuccessResult(
    data: const DriverRegistrationResultEntity(
      registrationId: '',
      restaurantId: '',
      restaurantName: '',
      phone: '',
      status: '',
      message: '',
    ),
  );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async => ApiSuccessResult(
    data: const DriverRegistrationResultEntity(
      registrationId: '',
      restaurantId: '',
      restaurantName: '',
      phone: '',
      status: '',
      message: '',
    ),
  );
}

void main() {
  final repository = _FakeDriverRegistrationRepository();

  test('GetDriverVehicleTypesUseCase returns vehicle type entities', () async {
    final result = await GetDriverVehicleTypesUseCase(repository)();

    expect(result, isA<ApiSuccessResult<List<DriverVehicleTypeEntity>>>());
    expect(
      (result as ApiSuccessResult<List<DriverVehicleTypeEntity>>)
          .data
          .single
          .iconKey,
      'car',
    );
  });

  test(
    'GetDriverVehicleColorsUseCase returns vehicle color entities',
    () async {
      final result = await GetDriverVehicleColorsUseCase(repository)();

      expect(result, isA<ApiSuccessResult<List<DriverVehicleColorEntity>>>());
      expect(
        (result as ApiSuccessResult<List<DriverVehicleColorEntity>>)
            .data
            .single
            .nameEn,
        'Black',
      );
    },
  );

  test(
    'SearchDriverVehicleModelsUseCase forwards search, type, and limit',
    () async {
      final result = await SearchDriverVehicleModelsUseCase(repository)(
        search: 'cam',
        vehicleType: 'Car',
        limit: 12,
      );

      expect(result, isA<ApiSuccessResult<List<DriverVehicleModelEntity>>>());
      expect(
        (result as ApiSuccessResult<List<DriverVehicleModelEntity>>)
            .data
            .single
            .value,
        'cam/Car/12',
      );
    },
  );
}
