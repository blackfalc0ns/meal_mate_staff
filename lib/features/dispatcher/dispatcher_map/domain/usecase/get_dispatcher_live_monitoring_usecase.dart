import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_live_monitoring_entity.dart';
import '../repo/dispatcher_map_repository.dart';

class GetDispatcherLiveMonitoringUseCase {
  const GetDispatcherLiveMonitoringUseCase(this._repository);

  final DispatcherMapRepository _repository;

  Future<ApiResult<DispatcherLiveMonitoringEntity>> call({
    String? restaurantId,
    String? status,
  }) {
    return _repository.getLiveMonitoring(
      restaurantId: restaurantId,
      status: status,
    );
  }
}
