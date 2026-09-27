import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_delivery_manifest_entity.dart';
import '../entities/driver_orders_query_entity.dart';
import '../repo/driver_orders_repository.dart';

@injectable
class GetDriverOrdersUseCase {
  const GetDriverOrdersUseCase(this._repository);

  final DriverOrdersRepository _repository;

  Future<ApiResult<DriverDeliveryManifestEntity>> call(
    DriverOrdersQueryEntity query,
  ) {
    return _repository.getDriverOrders(query);
  }
}
