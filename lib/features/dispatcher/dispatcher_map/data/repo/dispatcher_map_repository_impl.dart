import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_live_monitoring_entity.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/dispatcher_map_realtime_event.dart';
import '../../domain/repo/dispatcher_map_repository.dart';
import '../data_source/dispatcher_map_remote_data_source.dart';
import '../mapper/dispatcher_map_mapper.dart';

class DispatcherMapRepositoryImpl implements DispatcherMapRepository {
  DispatcherMapRepositoryImpl(this._remoteDataSource);

  final DispatcherMapRemoteDataSource _remoteDataSource;
  DispatcherMapConnectionStatus _currentStatus =
      DispatcherMapConnectionStatus.disconnected;

  @override
  Future<ApiResult<DispatcherLiveMonitoringEntity>> getLiveMonitoring({
    String? restaurantId,
    String? status,
  }) {
    return safeApiCall(() async {
      final dto = await _remoteDataSource.getLiveMonitoring(
        restaurantId: restaurantId,
        status: status,
      );
      return dto.toEntity();
    });
  }

  @override
  Stream<DispatcherMapRealtimeEvent> get realtimeEvents =>
      _remoteDataSource.realtimeEvents.map((eventDto) => eventDto.toDomain());

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      _remoteDataSource.connectionStatuses.map((status) {
        _currentStatus = status;
        return status;
      });

  @override
  DispatcherMapConnectionStatus get currentConnectionStatus => _currentStatus;

  @override
  Future<void> startRealtimeUpdates() => _remoteDataSource.startRealtime();

  @override
  Future<void> stopRealtimeUpdates() => _remoteDataSource.stopRealtime();

  @override
  Future<void> disposeRealtime() => _remoteDataSource.disposeRealtime();
}
