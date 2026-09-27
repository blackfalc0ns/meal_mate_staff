import '../models/response/driver_call_proxy_response_dto.dart';
import '../models/response/driver_delivery_manifest_response_dto.dart';

abstract interface class DriverOrdersRemoteDataSource {
  Future<DriverDeliveryManifestResponseDto> getDriverOrders({
    required String statusFilter,
    String? search,
  });

  Future<DriverCallProxyResponseDto> getDriverCallProxy(String boxId);
}
