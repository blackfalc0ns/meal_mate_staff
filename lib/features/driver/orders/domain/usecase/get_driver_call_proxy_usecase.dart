import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_call_proxy_entity.dart';
import '../repo/driver_orders_repository.dart';

@injectable
class GetDriverCallProxyUseCase {
  const GetDriverCallProxyUseCase(this._repository);

  final DriverOrdersRepository _repository;

  Future<ApiResult<DriverCallProxyEntity>> call(String boxId) {
    return _repository.getDriverCallProxy(boxId);
  }
}
