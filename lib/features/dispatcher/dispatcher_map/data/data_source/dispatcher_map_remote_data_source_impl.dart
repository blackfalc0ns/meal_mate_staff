import '../../../../../core/network/api_services.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../models/response/dispatcher_live_monitoring_response_dto.dart';
import '../realtime/dispatcher_map_realtime_client.dart';
import '../realtime/dispatcher_map_realtime_event_dto.dart';
import 'dispatcher_map_remote_data_source.dart';

class DispatcherMapRemoteDataSourceImpl
    implements DispatcherMapRemoteDataSource {
  DispatcherMapRemoteDataSourceImpl(this._apiServices, this._realtimeClient);

  final ApiServices _apiServices;
  final DispatcherMapRealtimeClient _realtimeClient;

  @override
  Future<DispatcherLiveMonitoringResponseDto> getLiveMonitoring({
    String? restaurantId,
    String? status,
  }) {
    return _apiServices.getDispatcherLiveMonitoring(
      restaurantId: restaurantId,
      status: status,
    );
  }

  @override
  Stream<DispatcherMapRealtimeEventDto> get realtimeEvents =>
      _realtimeClient.events;

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      _realtimeClient.connectionStatuses;

  static const String mapOwnerId = 'dispatcher-map';

  @override
  Future<void> startRealtime() => _realtimeClient.acquire(mapOwnerId);

  @override
  Future<void> stopRealtime() => _realtimeClient.release(mapOwnerId);

  @override
  Future<void> disposeRealtime() => _realtimeClient.dispose();
}
