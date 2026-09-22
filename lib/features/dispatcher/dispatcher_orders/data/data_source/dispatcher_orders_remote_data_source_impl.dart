import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import '../models/response/dispatcher_order_queue_response_dto.dart';
import 'dispatcher_orders_remote_data_source.dart';

extension DispatcherFilterTypeWire on DispatcherFilterType {
  String toWireValue() {
    return switch (this) {
      DispatcherFilterType.all => 'All',
      DispatcherFilterType.pendingAssignment => 'Pending',
      DispatcherFilterType.assigned => 'Assigned',
      DispatcherFilterType.inDelivery => 'InDelivery',
      DispatcherFilterType.problems => 'Issues',
    };
  }
}

@Injectable(as: DispatcherOrdersRemoteDataSource)
class DispatcherOrdersRemoteDataSourceImpl
    implements DispatcherOrdersRemoteDataSource {
  DispatcherOrdersRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DispatcherOrderQueueResponseDto> getQueue(String filter) {
    return _apiServices.getDispatcherOrdersQueue(filter);
  }
}
