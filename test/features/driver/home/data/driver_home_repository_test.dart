import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/home/data/datasources/driver_home_fake_datasource.dart';
import 'package:meal_mate_delivery/features/driver/home/data/repositories/driver_home_repository_impl.dart';

void main() {
  late DriverHomeFakeDataSource dataSource;
  late DriverHomeRepositoryImpl repository;

  setUp(() {
    dataSource = DriverHomeFakeDataSource();
    repository = DriverHomeRepositoryImpl(dataSource);
  });

  test('getStartWorkOverview returns valid initial state', () async {
    final result = await repository.getStartWorkOverview();
    expect(result.isAvailable, isFalse);
    expect(result.metrics.length, 3);
    expect(result.requirements.length, 3);
  });

  test('getActiveHomeOverview returns valid delivery state', () async {
    final result = await repository.getActiveHomeOverview();
    expect(result.isInDelivery, isTrue);
    expect(result.currentOrder.orderCode, 'BX-458722');
    expect(result.summary.totalOrdersCount, 8);
    expect(result.performance.onTimeRate, '92%');
  });

  test('startShift marks shift active in data source', () async {
    expect(dataSource.isShiftActive, isFalse);
    await repository.startShift();
    expect(dataSource.isShiftActive, isTrue);
  });
}
