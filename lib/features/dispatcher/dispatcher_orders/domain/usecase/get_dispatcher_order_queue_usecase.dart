import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_filter_type.dart';
import '../entities/dispatcher_order_queue_entity.dart';
import '../repo/dispatcher_orders_repository.dart';

@injectable
class GetDispatcherOrderQueueUseCase {
  GetDispatcherOrderQueueUseCase(this._repository);

  final DispatcherOrdersRepository _repository;

  Future<ApiResult<DispatcherOrderQueueEntity>> call(
    DispatcherFilterType filter,
  ) {
    return _repository.getQueue(filter);
  }
}
