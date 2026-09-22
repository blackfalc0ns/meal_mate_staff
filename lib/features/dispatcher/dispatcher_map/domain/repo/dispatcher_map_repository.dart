import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_live_monitoring_entity.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/dispatcher_map_realtime_event.dart';

abstract class DispatcherMapRepository {
  Future<ApiResult<DispatcherLiveMonitoringEntity>> getLiveMonitoring({
    String? restaurantId,
    String? status,
  });

  Stream<DispatcherMapRealtimeEvent> get realtimeEvents;
  Stream<DispatcherMapConnectionStatus> get connectionStatuses;
  DispatcherMapConnectionStatus get currentConnectionStatus;

  Future<void> startRealtimeUpdates();
  Future<void> stopRealtimeUpdates();
  Future<void> disposeRealtime();
}
