import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_call_proxy_entity.dart';
import '../../domain/entities/driver_delivery_manifest_entity.dart';
import '../../domain/entities/driver_orders_query_entity.dart';
import '../../domain/repo/driver_orders_repository.dart';
import '../data_source/driver_orders_remote_data_source.dart';
import '../mapper/driver_delivery_manifest_mapper.dart';

@LazySingleton(as: DriverOrdersRepository)
class DriverOrdersRepositoryImpl implements DriverOrdersRepository {
  const DriverOrdersRepositoryImpl(this._remoteDataSource);

  final DriverOrdersRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverDeliveryManifestEntity>> getDriverOrders(
    DriverOrdersQueryEntity query,
  ) {
    return safeApiCall<DriverDeliveryManifestEntity>(() async {
      final dto = await _remoteDataSource.getDriverOrders(
        statusFilter: query.filter.wireValue,
        search: query.search,
      );
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverCallProxyEntity>> getDriverCallProxy(String boxId) {
    return safeApiCall<DriverCallProxyEntity>(() async {
      final dto = await _remoteDataSource.getDriverCallProxy(boxId);
      return dto.toEntity();
    });
  }
}
