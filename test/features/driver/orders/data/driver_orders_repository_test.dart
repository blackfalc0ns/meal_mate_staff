import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/data_source/driver_orders_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_call_proxy_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_delivery_manifest_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/repo/driver_orders_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_filter.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_query_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_orders_repository.dart';

class _FakeDriverOrdersRemoteDataSource implements DriverOrdersRemoteDataSource {
  String? lastStatusFilter;
  String? lastSearch;
  String? lastBoxId;
  bool shouldThrowDio = false;

  DriverDeliveryManifestResponseDto ordersResponse =
      const DriverDeliveryManifestResponseDto(
    tripId: 'trip-abc',
    tripCode: 'TRP-123',
    stops: [
      DriverDeliveryStopResponseDto(
        tripStopId: 'ts1',
        boxId: 'b1',
        boxCode: 'BX-1',
        sequenceNumber: 1,
      ),
    ],
  );

  DriverCallProxyResponseDto proxyResponse =
      const DriverCallProxyResponseDto(
    boxId: 'box-1',
    callableUri: 'tel:+96512345678',
    phoneNumber: '+96512345678',
  );

  @override
  Future<DriverDeliveryManifestResponseDto> getDriverOrders({
    required String statusFilter,
    String? search,
  }) async {
    lastStatusFilter = statusFilter;
    lastSearch = search;
    if (shouldThrowDio) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/orders'),
        type: DioExceptionType.connectionError,
      );
    }
    return ordersResponse;
  }

  @override
  Future<DriverCallProxyResponseDto> getDriverCallProxy(String boxId) async {
    lastBoxId = boxId;
    return proxyResponse;
  }
}

void main() {
  late _FakeDriverOrdersRemoteDataSource fakeRemoteDataSource;
  late DriverOrdersRepository repository;

  setUp(() {
    fakeRemoteDataSource = _FakeDriverOrdersRemoteDataSource();
    repository = DriverOrdersRepositoryImpl(fakeRemoteDataSource);
  });

  group('DriverOrdersRepositoryImpl', () {
    test('returns mapped entity wrapped in ApiSuccessResult on success', () async {
      final result = await repository.getDriverOrders(
        const DriverOrdersQueryEntity(
          filter: DriverOrdersFilter.inProgress,
          search: 'BX-1',
        ),
      );

      expect(result, isA<ApiSuccessResult<DriverDeliveryManifestEntity>>());
      final entity = (result as ApiSuccessResult<DriverDeliveryManifestEntity>).data;
      expect(entity.tripId, 'trip-abc');
      expect(entity.stops.length, 1);
      expect(entity.stops.first.boxCode, 'BX-1');
      expect(fakeRemoteDataSource.lastStatusFilter, 'InProgress');
      expect(fakeRemoteDataSource.lastSearch, 'BX-1');
    });

    test('wraps DioException in ApiErrorResult via safeApiCall', () async {
      fakeRemoteDataSource.shouldThrowDio = true;

      final result = await repository.getDriverOrders(
        const DriverOrdersQueryEntity(filter: DriverOrdersFilter.all),
      );

      expect(result, isA<ApiErrorResult<DriverDeliveryManifestEntity>>());
    });

    test('returns mapped call proxy entity on success', () async {
      final result = await repository.getDriverCallProxy('box-1');

      expect(result, isA<ApiSuccessResult>());
      final entity = (result as ApiSuccessResult).data;
      expect(entity.boxId, 'box-1');
      expect(entity.phoneNumber, '+96512345678');
      expect(fakeRemoteDataSource.lastBoxId, 'box-1');
    });
  });
}
