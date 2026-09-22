import '../models/response/dispatcher_order_queue_response_dto.dart';

abstract interface class DispatcherOrdersRemoteDataSource {
  Future<DispatcherOrderQueueResponseDto> getQueue(String filter);
}
