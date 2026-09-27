import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_call_proxy_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_filter.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_query_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_orders_repository.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_call_proxy_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_orders_usecase.dart';

class _FakeDriverOrdersRepository implements DriverOrdersRepository {
  DriverOrdersQueryEntity? lastQuery;
  String? lastBoxId;

  DriverDeliveryManifestEntity manifestResponse = DriverDeliveryManifestEntity(
    totalCount: 1,
    inProgressCount: 0,
    deliveredCount: 1,
    failedCount: 0,
    stops: const [],
  );

  DriverCallProxyEntity proxyResponse = const DriverCallProxyEntity(
    boxId: 'box-777',
    callableUri: 'tel:+96500000000',
  );

  @override
  Future<ApiResult<DriverDeliveryManifestEntity>> getDriverOrders(
    DriverOrdersQueryEntity query,
  ) async {
    lastQuery = query;
    return ApiSuccessResult(data: manifestResponse);
  }

  @override
  Future<ApiResult<DriverCallProxyEntity>> getDriverCallProxy(
    String boxId,
  ) async {
    lastBoxId = boxId;
    return ApiSuccessResult(data: proxyResponse);
  }
}

void main() {
  late _FakeDriverOrdersRepository fakeRepository;
  late GetDriverOrdersUseCase getDriverOrdersUseCase;
  late GetDriverCallProxyUseCase getDriverCallProxyUseCase;

  setUp(() {
    fakeRepository = _FakeDriverOrdersRepository();
    getDriverOrdersUseCase = GetDriverOrdersUseCase(fakeRepository);
    getDriverCallProxyUseCase = GetDriverCallProxyUseCase(fakeRepository);
  });

  group('Driver Orders UseCases', () {
    test('GetDriverOrdersUseCase forwards query to repository', () async {
      const query = DriverOrdersQueryEntity(
        filter: DriverOrdersFilter.delivered,
        search: 'Ahmed',
      );

      final result = await getDriverOrdersUseCase(query);

      expect(result, isA<ApiSuccessResult<DriverDeliveryManifestEntity>>());
      expect(fakeRepository.lastQuery, query);
    });

    test('GetDriverCallProxyUseCase forwards boxId to repository', () async {
      final result = await getDriverCallProxyUseCase('box-777');

      expect(result, isA<ApiSuccessResult<DriverCallProxyEntity>>());
      expect(fakeRepository.lastBoxId, 'box-777');
    });
  });
}
