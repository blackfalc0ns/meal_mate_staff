import '../../../../../core/network/api_results.dart';
import '../entities/driver_call_proxy_entity.dart';
import '../entities/driver_delivery_manifest_entity.dart';
import '../entities/driver_orders_query_entity.dart';

abstract interface class DriverOrdersRepository {
  Future<ApiResult<DriverDeliveryManifestEntity>> getDriverOrders(
    DriverOrdersQueryEntity query,
  );

  Future<ApiResult<DriverCallProxyEntity>> getDriverCallProxy(String boxId);
}
