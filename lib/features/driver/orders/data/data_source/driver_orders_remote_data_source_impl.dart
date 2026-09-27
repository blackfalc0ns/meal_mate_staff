import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/driver_call_proxy_response_dto.dart';
import '../models/response/driver_delivery_manifest_response_dto.dart';
import 'driver_orders_remote_data_source.dart';

@LazySingleton(as: DriverOrdersRemoteDataSource)
class DriverOrdersRemoteDataSourceImpl implements DriverOrdersRemoteDataSource {
  const DriverOrdersRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverDeliveryManifestResponseDto> getDriverOrders({
    required String statusFilter,
    String? search,
  }) {
    final trimmedSearch = (search != null && search.trim().isNotEmpty)
        ? search.trim()
        : null;

    return _apiServices.getDriverOrders(
      statusFilter: statusFilter,
      search: trimmedSearch,
    );
  }

  @override
  Future<DriverCallProxyResponseDto> getDriverCallProxy(String boxId) {
    return _apiServices.getDriverCallProxy(boxId);
  }
}
