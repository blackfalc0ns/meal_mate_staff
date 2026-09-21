import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/core/network/network_constants.dart';
import 'package:meal_mate_delivery/features/register/data/mapper/driver_registration_mapper.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_color_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_model_response_dto.dart';
import 'package:meal_mate_delivery/features/register/data/models/response/driver_vehicle_type_response_dto.dart';

void main() {
  group('Driver vehicle catalog DTOs', () {
    test('vehicle type DTO preserves the literal backend fields', () {
      final dto = DriverVehicleTypeResponseDto.fromJson(const {
        'code': 'Car',
        'nameAr': 'سيارة',
        'nameEn': 'Car',
        'iconKey': 'car',
      });

      expect(dto.code, 'Car');
      expect(dto.nameAr, 'سيارة');
      expect(dto.nameEn, 'Car');
      expect(dto.iconKey, 'car');
      expect(dto.toJson(), const {
        'code': 'Car',
        'nameAr': 'سيارة',
        'nameEn': 'Car',
        'iconKey': 'car',
      });
    });

    test('vehicle color DTO preserves the literal backend fields', () {
      final dto = DriverVehicleColorResponseDto.fromJson(const {
        'hex': '#5E35B1',
        'nameAr': 'بنفسجي',
        'nameEn': 'Purple',
        'isDefault': true,
        'displayOrder': 2,
      });

      expect(dto.hex, '#5E35B1');
      expect(dto.nameAr, 'بنفسجي');
      expect(dto.nameEn, 'Purple');
      expect(dto.isDefault, isTrue);
      expect(dto.displayOrder, 2);
      expect(dto.toJson(), const {
        'hex': '#5E35B1',
        'nameAr': 'بنفسجي',
        'nameEn': 'Purple',
        'isDefault': true,
        'displayOrder': 2,
      });
    });

    test('vehicle model DTO preserves the literal backend fields', () {
      final dto = DriverVehicleModelResponseDto.fromJson(const {
        'value': 'Toyota Camry',
        'makeCode': 'Toyota',
        'makeNameAr': 'تويوتا',
        'makeNameEn': 'Toyota',
        'modelCode': 'Camry',
        'modelNameAr': 'كامري',
        'modelNameEn': 'Camry',
        'fullNameAr': 'تويوتا كامري',
        'fullNameEn': 'Toyota Camry',
        'vehicleType': 'Car',
      });

      expect(dto.value, 'Toyota Camry');
      expect(dto.makeCode, 'Toyota');
      expect(dto.makeNameAr, 'تويوتا');
      expect(dto.makeNameEn, 'Toyota');
      expect(dto.modelCode, 'Camry');
      expect(dto.modelNameAr, 'كامري');
      expect(dto.modelNameEn, 'Camry');
      expect(dto.fullNameAr, 'تويوتا كامري');
      expect(dto.fullNameEn, 'Toyota Camry');
      expect(dto.vehicleType, 'Car');
    });

    test('catalog DTOs keep absent backend fields nullable', () {
      final type = DriverVehicleTypeResponseDto.fromJson(const {});
      final color = DriverVehicleColorResponseDto.fromJson(const {});
      final model = DriverVehicleModelResponseDto.fromJson(const {});

      expect(type.code, isNull);
      expect(type.nameAr, isNull);
      expect(type.nameEn, isNull);
      expect(type.iconKey, isNull);
      expect(color.hex, isNull);
      expect(color.nameAr, isNull);
      expect(color.nameEn, isNull);
      expect(color.isDefault, isNull);
      expect(color.displayOrder, isNull);
      expect(model.value, isNull);
      expect(model.makeCode, isNull);
      expect(model.makeNameAr, isNull);
      expect(model.makeNameEn, isNull);
      expect(model.modelCode, isNull);
      expect(model.modelNameAr, isNull);
      expect(model.modelNameEn, isNull);
      expect(model.fullNameAr, isNull);
      expect(model.fullNameEn, isNull);
      expect(model.vehicleType, isNull);
    });
  });

  group('Driver vehicle catalog mappers', () {
    test('vehicle catalog mappers provide safe non-null domain fallbacks', () {
      const typeDto = DriverVehicleTypeResponseDto(nameEn: 'Car');
      const colorDto = DriverVehicleColorResponseDto(
        hex: '5e35b1',
        nameEn: 'Purple',
      );
      const modelDto = DriverVehicleModelResponseDto(
        makeNameEn: 'Toyota',
        modelNameEn: 'Camry',
      );

      final type = typeDto.toEntity();
      final color = colorDto.toEntity();
      final model = modelDto.toEntity();

      expect(type.code, '');
      expect(type.nameAr, 'Car');
      expect(type.nameEn, 'Car');
      expect(type.iconKey, '');
      expect(color.hex, '#5E35B1');
      expect(color.nameAr, 'Purple');
      expect(color.nameEn, 'Purple');
      expect(color.isDefault, isFalse);
      expect(color.displayOrder, 0);
      expect(model.value, '');
      expect(model.makeCode, '');
      expect(model.makeNameAr, 'Toyota');
      expect(model.makeNameEn, 'Toyota');
      expect(model.modelCode, '');
      expect(model.modelNameAr, 'Camry');
      expect(model.modelNameEn, 'Camry');
      expect(model.fullNameAr, 'Toyota Camry');
      expect(model.fullNameEn, 'Toyota Camry');
      expect(model.vehicleType, '');
    });

    test('vehicle color mapper normalizes lowercase and ARGB HEX values', () {
      const prefixlessRgb = DriverVehicleColorResponseDto(hex: '5e35b1');
      const prefixedArgb = DriverVehicleColorResponseDto(hex: '#805e35b1');
      const prefixlessArgb = DriverVehicleColorResponseDto(hex: 'ff5e35b1');

      expect(prefixlessRgb.toEntity().hex, '#5E35B1');
      expect(prefixedArgb.toEntity().hex, '#5E35B1');
      expect(prefixlessArgb.toEntity().hex, '#5E35B1');
    });

    test(
      'vehicle color mapper maps missing and malformed HEX to invalid sentinel',
      () {
        const missing = DriverVehicleColorResponseDto();
        const invalidCharacter = DriverVehicleColorResponseDto(hex: '#5E35BZ');
        const invalidLength = DriverVehicleColorResponseDto(hex: '#5E35B');

        expect(missing.toEntity().hex, isEmpty);
        expect(invalidCharacter.toEntity().hex, isEmpty);
        expect(invalidLength.toEntity().hex, isEmpty);
      },
    );
  });

  group('Driver vehicle catalog endpoints', () {
    test(
      'catalog endpoints use GET routes and model search query defaults',
      () async {
        late RequestOptions lastRequest;
        final dio = Dio(BaseOptions(baseUrl: NetworkConstants.baseUrl))
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                lastRequest = options;
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: <dynamic>[],
                  ),
                );
              },
            ),
          );
        final apiServices = ApiServices(dio);

        await apiServices.getDriverVehicleTypes();
        expect(lastRequest.method, 'GET');
        expect(lastRequest.path, EndPoints.driverVehicleTypes);

        await apiServices.getDriverVehicleColors();
        expect(lastRequest.method, 'GET');
        expect(lastRequest.path, EndPoints.driverVehicleColors);

        await apiServices.searchDriverVehicleModels(
          search: 'cam',
          vehicleType: 'Car',
        );
        expect(lastRequest.method, 'GET');
        expect(lastRequest.path, EndPoints.driverVehicleModels);
        expect(lastRequest.queryParameters, {
          'search': 'cam',
          'vehicleType': 'Car',
          'limit': 40,
        });
      },
    );
  });
}
