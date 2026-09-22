import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import '../../domain/entities/dispatcher_order_queue_entity.dart';
import '../../domain/repo/dispatcher_orders_repository.dart';
import '../data_source/dispatcher_orders_remote_data_source.dart';
import '../data_source/dispatcher_orders_remote_data_source_impl.dart';
import '../mapper/dispatcher_orders_mapper.dart';

@Injectable(as: DispatcherOrdersRepository)
class DispatcherOrdersRepositoryImpl implements DispatcherOrdersRepository {
  DispatcherOrdersRepositoryImpl(this._remoteDataSource);

  final DispatcherOrdersRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DispatcherOrderQueueEntity>> getQueue(
    DispatcherFilterType filter,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getQueue(filter.toWireValue());
      return response.toEntity();
    });
  }
}
