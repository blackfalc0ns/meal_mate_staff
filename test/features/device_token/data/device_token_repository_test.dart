import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/device_token/data/data_source/device_token_remote_data_source.dart';
import 'package:meal_mate_delivery/features/device_token/data/models/request/driver_device_token_request_dto.dart';
import 'package:meal_mate_delivery/features/device_token/data/models/request/restaurant_device_token_request_dto.dart';
import 'package:meal_mate_delivery/features/device_token/data/repo/device_token_repository_impl.dart';

class _FakeDeviceTokenRemoteDataSource implements DeviceTokenRemoteDataSource {
  DriverDeviceTokenRequestDto? lastDriverUpsert;
  String? lastDriverDeactivate;
  RestaurantDeviceTokenRequestDto? lastRestaurantUpsert;
  String? lastRestaurantDeactivate;
  bool shouldThrow = false;

  @override
  Future<void> upsertDriverToken(DriverDeviceTokenRequestDto request) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/device-token'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/driver/device-token'),
          statusCode: 400,
          data: {'title': 'Invalid token', 'status': 400},
        ),
      );
    }
    lastDriverUpsert = request;
  }

  @override
  Future<void> deactivateDriverToken(String token) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/device-token'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/driver/device-token'),
          statusCode: 500,
        ),
      );
    }
    lastDriverDeactivate = token;
  }

  @override
  Future<void> upsertRestaurantToken(
    RestaurantDeviceTokenRequestDto request,
  ) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/restaurants/device-tokens',
        ),
        response: Response(
          requestOptions: RequestOptions(
            path: '/api/v1/restaurants/device-tokens',
          ),
          statusCode: 401,
        ),
      );
    }
    lastRestaurantUpsert = request;
  }

  @override
  Future<void> deactivateRestaurantToken(String token) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/restaurants/device-tokens',
        ),
        response: Response(
          requestOptions: RequestOptions(
            path: '/api/v1/restaurants/device-tokens',
          ),
          statusCode: 500,
        ),
      );
    }
    lastRestaurantDeactivate = token;
  }
}

void main() {
  late _FakeDeviceTokenRemoteDataSource fakeRemoteDataSource;
  late DeviceTokenRepositoryImpl repository;

  setUp(() {
    fakeRemoteDataSource = _FakeDeviceTokenRemoteDataSource();
    repository = DeviceTokenRepositoryImpl(fakeRemoteDataSource);
  });

  group('DeviceTokenRepositoryImpl', () {
    test(
      'upsertDriverToken returns ApiSuccessResult and passes fields',
      () async {
        final result = await repository.upsertDriverToken(
          token: 'token-123',
          platform: 'Android',
          deviceId: 'device-abc',
          registrationId: 'reg-456',
        );

        expect(result, isA<ApiSuccessResult<void>>());
        expect(fakeRemoteDataSource.lastDriverUpsert?.token, 'token-123');
        expect(fakeRemoteDataSource.lastDriverUpsert?.platform, 'Android');
        expect(fakeRemoteDataSource.lastDriverUpsert?.deviceId, 'device-abc');
        expect(
          fakeRemoteDataSource.lastDriverUpsert?.registrationId,
          'reg-456',
        );
      },
    );

    test('upsertDriverToken returns ApiErrorResult on DioException', () async {
      fakeRemoteDataSource.shouldThrow = true;

      final result = await repository.upsertDriverToken(
        token: 'token-123',
        platform: 'Android',
        deviceId: 'device-abc',
      );

      expect(result, isA<ApiErrorResult<void>>());
    });

    test('deactivateDriverToken returns ApiSuccessResult', () async {
      final result = await repository.deactivateDriverToken(token: 'token-123');

      expect(result, isA<ApiSuccessResult<void>>());
      expect(fakeRemoteDataSource.lastDriverDeactivate, 'token-123');
    });

    test('deactivateDriverToken returns ApiErrorResult on error', () async {
      fakeRemoteDataSource.shouldThrow = true;

      final result = await repository.deactivateDriverToken(token: 'token-123');

      expect(result, isA<ApiErrorResult<void>>());
    });

    test('upsertRestaurantToken returns ApiSuccessResult', () async {
      final result = await repository.upsertRestaurantToken(
        token: 'token-xyz',
        platform: 'iOS',
        deviceId: 'device-def',
      );

      expect(result, isA<ApiSuccessResult<void>>());
      expect(fakeRemoteDataSource.lastRestaurantUpsert?.token, 'token-xyz');
      expect(fakeRemoteDataSource.lastRestaurantUpsert?.platform, 'iOS');
      expect(fakeRemoteDataSource.lastRestaurantUpsert?.deviceId, 'device-def');
    });

    test('upsertRestaurantToken returns ApiErrorResult on error', () async {
      fakeRemoteDataSource.shouldThrow = true;

      final result = await repository.upsertRestaurantToken(
        token: 'token-xyz',
        platform: 'iOS',
        deviceId: 'device-def',
      );

      expect(result, isA<ApiErrorResult<void>>());
    });

    test('deactivateRestaurantToken returns ApiSuccessResult', () async {
      final result = await repository.deactivateRestaurantToken(
        token: 'token-xyz',
      );

      expect(result, isA<ApiSuccessResult<void>>());
      expect(fakeRemoteDataSource.lastRestaurantDeactivate, 'token-xyz');
    });

    test('deactivateRestaurantToken returns ApiErrorResult on error', () async {
      fakeRemoteDataSource.shouldThrow = true;

      final result = await repository.deactivateRestaurantToken(
        token: 'token-xyz',
      );

      expect(result, isA<ApiErrorResult<void>>());
    });
  });
}
