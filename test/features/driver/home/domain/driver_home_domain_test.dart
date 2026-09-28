import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_active_home_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_current_order_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_goal_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_performance_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_summary_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_start_work_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/repositories/driver_home_repository.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecases/get_driver_active_home_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecases/get_driver_start_work_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecases/start_driver_shift_usecase.dart';

class _FakeDriverHomeRepository implements DriverHomeRepository {
  bool shiftStarted = false;

  @override
  Future<DriverStartWorkEntity> getStartWorkOverview() async {
    return const DriverStartWorkEntity(
      isAvailable: false,
      statusLabel: 'غير متاح',
      statusDescription: 'أنت غير متاح لاستلام الطلبات',
      metrics: [],
      requirements: [],
    );
  }

  @override
  Future<DriverActiveHomeEntity> getActiveHomeOverview() async {
    return const DriverActiveHomeEntity(
      isInDelivery: true,
      currentLocation: 'السالمية',
      goal: DriverDailyGoalEntity(
        completedOrders: 5,
        totalOrdersTarget: 8,
        performanceLevel: 'جيد',
      ),
      currentOrder: DriverCurrentOrderEntity(
        orderId: '1',
        orderCode: 'BX-458722',
        clientName: 'محمد علي',
        address: 'شارع الخليج العربي',
        mealsCount: 3,
        deliveryTime: '09:20 ص',
        imageAsset: 'assets/images/dispatcher/driver_box_3d.png',
      ),
      summary: DriverDailySummaryEntity(
        incompleteCount: 1,
        inDeliveryCount: 2,
        deliveredCount: 5,
        totalOrdersCount: 8,
      ),
      performance: DriverDailyPerformanceEntity(
        averageDeliveryTime: '18 دقيقة',
        distanceCovered: '32.4 كم',
        onTimeRate: '92%',
      ),
    );
  }

  @override
  Future<void> startShift() async {
    shiftStarted = true;
  }
}

void main() {
  late _FakeDriverHomeRepository repository;
  late GetDriverStartWorkUseCase getStartWorkUseCase;
  late GetDriverActiveHomeUseCase getActiveHomeUseCase;
  late StartDriverShiftUseCase startShiftUseCase;

  setUp(() {
    repository = _FakeDriverHomeRepository();
    getStartWorkUseCase = GetDriverStartWorkUseCase(repository);
    getActiveHomeUseCase = GetDriverActiveHomeUseCase(repository);
    startShiftUseCase = StartDriverShiftUseCase(repository);
  });

  test('GetDriverStartWorkUseCase returns start work entity', () async {
    final result = await getStartWorkUseCase();
    expect(result.isAvailable, isFalse);
    expect(result.statusLabel, 'غير متاح');
  });

  test('GetDriverActiveHomeUseCase returns active home entity with goal calculations', () async {
    final result = await getActiveHomeUseCase();
    expect(result.isInDelivery, isTrue);
    expect(result.goal.completedOrders, 5);
    expect(result.goal.totalOrdersTarget, 8);
    expect(result.goal.remainingOrders, 3);
    expect(result.goal.progress, closeTo(0.625, 0.001));
    expect(result.currentOrder.orderCode, 'BX-458722');
  });

  test('StartDriverShiftUseCase starts shift', () async {
    await startShiftUseCase();
    expect(repository.shiftStarted, isTrue);
  });
}
