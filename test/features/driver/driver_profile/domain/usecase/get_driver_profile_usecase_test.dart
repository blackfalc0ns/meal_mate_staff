import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/repo/driver_profile_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/usecase/get_driver_profile_usecase.dart';

class _FakeDriverProfileRepository implements DriverProfileRepository {
  ApiResult<DriverProfileEntity>? result;

  @override
  Future<ApiResult<DriverProfileEntity>> getProfile() async {
    return result ??
        ApiSuccessResult(
          data: const DriverProfileEntity(
            driverProfileId: '1',
            fullName: 'Test Driver',
            driverDescription: 'Desc',
            driverCode: 'CODE1',
            isOnline: true,
            status: 'Active',
            statusText: 'Active',
            reviewsCount: 5,
            totalOrders: 10,
          ),
        );
  }
}

void main() {
  group('GetDriverProfileUseCase', () {
    test('delegates call directly to repository.getProfile()', () async {
      final repo = _FakeDriverProfileRepository();
      final useCase = GetDriverProfileUseCase(repo);

      final result = await useCase();

      expect(result, isA<ApiSuccessResult<DriverProfileEntity>>());
      final data = (result as ApiSuccessResult<DriverProfileEntity>).data;
      expect(data.driverProfileId, '1');
      expect(data.fullName, 'Test Driver');
    });
  });
}
