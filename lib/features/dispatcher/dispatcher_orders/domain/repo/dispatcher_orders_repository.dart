import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_filter_type.dart';
import '../entities/dispatcher_order_queue_entity.dart';

abstract interface class DispatcherOrdersRepository {
  Future<ApiResult<DispatcherOrderQueueEntity>> getQueue(
    DispatcherFilterType filter,
  );
}
