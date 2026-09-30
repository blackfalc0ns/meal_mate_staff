import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/data/data_source/driver_profile_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/data/models/response/driver_profile_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/data/repo/driver_profile_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';

class _FakeDriverProfileRemoteDataSource
    implements DriverProfileRemoteDataSource {
  DriverProfileResponseDto? response;
  Exception? errorToThrow;

  @override
  Future<DriverProfileResponseDto> getProfile() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return response ?? const DriverProfileResponseDto();
  }
}

void main() {
  group('DriverProfileRepositoryImpl', () {
    late _FakeDriverProfileRemoteDataSource remote;
    late DriverProfileRepositoryImpl repository;

    setUp(() {
      remote = _FakeDriverProfileRemoteDataSource();
      repository = DriverProfileRepositoryImpl(remote);
    });

    test('maps the direct DTO response to a domain entity', () async {
      remote.response = const DriverProfileResponseDto(
        driverProfileId: 'drv-1',
        fullName: 'Ahmed',
      );

      final result = await repository.getProfile();

      expect(result, isA<ApiSuccessResult<DriverProfileEntity>>());
      final success = result as ApiSuccessResult<DriverProfileEntity>;
      expect(success.data.driverProfileId, 'drv-1');
      expect(success.data.fullName, 'Ahmed');
    });

    test(
        'returns typed failure when the remote source throws DioException',
        () async {
      remote.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/profile'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/driver/profile'),
          statusCode: 404,
        ),
      );

      final result = await repository.getProfile();

      expect(result, isA<ApiErrorResult<DriverProfileEntity>>());
    });
  });
}
