import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/register/data/data_source/driver_registration_remote_data_source.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_registration_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/request/driver_resubmit_request_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_file_upload_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_nationality_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_registration_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_restaurant_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_color_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_model_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_type_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/repo/driver_registration_repository_impl.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_color_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_model_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_type_entity.dart';

class _FakeDriverRegistrationRemoteDataSource
    implements DriverRegistrationRemoteDataSource {
  List<DriverVehicleTypeResponseDto> vehicleTypes = const [];
  List<DriverVehicleColorResponseDto> vehicleColors = const [];
  List<DriverVehicleModelResponseDto> vehicleModels = const [];
  Exception? errorToThrow;
  String? receivedSearch;
  String? receivedVehicleType;
  int? receivedLimit;

  @override
  Future<List<DriverRestaurantResponseDto>> getRestaurants() async => const [];

  @override
  Future<List<DriverNationalityResponseDto>> getNationalities() async =>
      const [];

  @override
  Future<List<DriverVehicleTypeResponseDto>> getVehicleTypes() async {
    if (errorToThrow != null) throw errorToThrow!;
    return vehicleTypes;
  }

  @override
  Future<List<DriverVehicleColorResponseDto>> getVehicleColors() async {
    if (errorToThrow != null) throw errorToThrow!;
    return vehicleColors;
  }

  @override
  Future<List<DriverVehicleModelResponseDto>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    receivedSearch = search;
    receivedVehicleType = vehicleType;
    receivedLimit = limit;
    return vehicleModels;
  }

  @override
  Future<DriverFileUploadResponseDto> uploadDocument(File file) async =>
      const DriverFileUploadResponseDto();

  @override
  Future<DriverRegistrationResponseDto> submitRegistration(
    DriverRegistrationRequestDto request,
  ) async => const DriverRegistrationResponseDto();

  @override
  Future<DriverRegistrationResponseDto> resubmitRegistration(
    String registrationId,
    DriverResubmitRequestDto request,
  ) async => const DriverRegistrationResponseDto();
}

void main() {
  group('Driver vehicle catalog repository', () {
    late _FakeDriverRegistrationRemoteDataSource remoteDataSource;
    late dynamic repository;

    setUp(() {
      remoteDataSource = _FakeDriverRegistrationRemoteDataSource();
      repository = DriverRegistrationRepositoryImpl(remoteDataSource);
    });

    test('maps vehicle type DTOs to domain entities', () async {
      remoteDataSource.vehicleTypes = const [
        DriverVehicleTypeResponseDto(
          code: 'Car',
          nameAr: 'سيارة',
          nameEn: 'Car',
          iconKey: 'car',
        ),
      ];

      final result = await repository.getVehicleTypes();

      expect(result, isA<ApiSuccessResult<List<DriverVehicleTypeEntity>>>());
      expect(
        (result as ApiSuccessResult<List<DriverVehicleTypeEntity>>)
            .data
            .single
            .code,
        'Car',
      );
    });

    test('maps vehicle color DTOs to domain entities', () async {
      remoteDataSource.vehicleColors = const [
        DriverVehicleColorResponseDto(
          hex: '#5E35B1',
          nameAr: 'بنفسجي',
          nameEn: 'Purple',
          isDefault: true,
          displayOrder: 2,
        ),
      ];

      final result = await repository.getVehicleColors();

      expect(result, isA<ApiSuccessResult<List<DriverVehicleColorEntity>>>());
      expect(
        (result as ApiSuccessResult<List<DriverVehicleColorEntity>>)
            .data
            .single
            .hex,
        '#5E35B1',
      );
    });

    test('maps vehicle models after forwarding each search argument', () async {
      remoteDataSource.vehicleModels = const [
        DriverVehicleModelResponseDto(
          value: 'Toyota Camry',
          makeCode: 'Toyota',
          makeNameEn: 'Toyota',
          modelCode: 'Camry',
          modelNameEn: 'Camry',
          fullNameEn: 'Toyota Camry',
          vehicleType: 'Car',
        ),
      ];

      final result = await repository.searchVehicleModels(
        search: 'cam',
        vehicleType: 'Car',
        limit: 12,
      );

      expect(remoteDataSource.receivedSearch, 'cam');
      expect(remoteDataSource.receivedVehicleType, 'Car');
      expect(remoteDataSource.receivedLimit, 12);
      expect(result, isA<ApiSuccessResult<List<DriverVehicleModelEntity>>>());
      expect(
        (result as ApiSuccessResult<List<DriverVehicleModelEntity>>)
            .data
            .single
            .fullNameEn,
        'Toyota Camry',
      );
    });

    test(
      'converts vehicle catalog transport failures into an ApiErrorResult',
      () async {
        remoteDataSource.errorToThrow = DioException(
          requestOptions: RequestOptions(path: '/driver-registration/vehicles'),
          type: DioExceptionType.connectionTimeout,
        );

        final result = await repository.getVehicleTypes();

        expect(result, isA<ApiErrorResult<List<DriverVehicleTypeEntity>>>());
      },
    );
  });
}
