import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/data_source/driver_orders_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/data_source/driver_orders_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_call_proxy_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/response/driver_delivery_manifest_response_dto.dart';

class _FakeApiServices implements ApiServices {
  String? lastStatusFilter;
  String? lastSearch;
  String? lastBoxId;

  DriverDeliveryManifestResponseDto ordersResponse =
      const DriverDeliveryManifestResponseDto(tripId: 'trip-1');
  DriverCallProxyResponseDto callProxyResponse =
      const DriverCallProxyResponseDto(
        boxId: 'box-999',
        callableUri: 'tel:+96512345678',
      );

  @override
  Future<DriverDeliveryManifestResponseDto> getDriverOrders({
    required String statusFilter,
    String? search,
  }) async {
    lastStatusFilter = statusFilter;
    lastSearch = search;
    return ordersResponse;
  }

  @override
  Future<DriverCallProxyResponseDto> getDriverCallProxy(String boxId) async {
    lastBoxId = boxId;
    return callProxyResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeApiServices fakeApiServices;
  late DriverOrdersRemoteDataSource remoteDataSource;

  setUp(() {
    fakeApiServices = _FakeApiServices();
    remoteDataSource = DriverOrdersRemoteDataSourceImpl(fakeApiServices);
  });

  group('DriverOrdersRemoteDataSourceImpl', () {
    test('forwards statusFilter and trimmed search to ApiServices', () async {
      final result = await remoteDataSource.getDriverOrders(
        statusFilter: 'InProgress',
        search: '  BX-123  ',
      );

      expect(result.tripId, 'trip-1');
      expect(fakeApiServices.lastStatusFilter, 'InProgress');
      expect(fakeApiServices.lastSearch, 'BX-123');
    });

    test('omits search when empty or whitespace only', () async {
      final result = await remoteDataSource.getDriverOrders(
        statusFilter: 'All',
        search: '   ',
      );

      expect(result.tripId, 'trip-1');
      expect(fakeApiServices.lastStatusFilter, 'All');
      expect(fakeApiServices.lastSearch, isNull);
    });

    test('forwards boxId to ApiServices for call proxy', () async {
      final result = await remoteDataSource.getDriverCallProxy('box-999');

      expect(result.boxId, 'box-999');
      expect(result.callableUri, 'tel:+96512345678');
      expect(fakeApiServices.lastBoxId, 'box-999');
    });
  });
}
