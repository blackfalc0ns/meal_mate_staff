import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/repo/driver_home_repository.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecase/get_driver_home_usecase.dart';

class _FakeDriverHomeRepository implements DriverHomeRepository {
  @override
  Future<ApiResult<DriverHomeEntity>> getDriverHome() async {
    return const ApiSuccessResult(
      data: DriverHomeEntity(
        driverId: 'drv-01',
        driverName: 'أحمد محمود',
        driverCode: 'DRV-1029',
        shiftStatus: DriverShiftStatus.active,
        isAvailable: true,
        currentStatusText: 'متاح للطلبات',
      ),
    );
  }
}

void main() {
  test('GetDriverHomeUseCase returns driver home entity', () async {
    final useCase = GetDriverHomeUseCase(_FakeDriverHomeRepository());
    final result = await useCase();

    expect(result, isA<ApiSuccessResult<DriverHomeEntity>>());
    final entity = (result as ApiSuccessResult<DriverHomeEntity>).data;
    expect(entity.driverId, 'drv-01');
    expect(entity.shiftStatus, DriverShiftStatus.active);
  });
}
