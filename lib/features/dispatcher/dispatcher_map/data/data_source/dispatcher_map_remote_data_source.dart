import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../models/response/dispatcher_live_monitoring_response_dto.dart';
import '../realtime/dispatcher_map_realtime_event_dto.dart';

abstract class DispatcherMapRemoteDataSource {
  Future<DispatcherLiveMonitoringResponseDto> getLiveMonitoring({
    String? restaurantId,
    String? status,
  });

  Stream<DispatcherMapRealtimeEventDto> get realtimeEvents;
  Stream<DispatcherMapConnectionStatus> get connectionStatuses;

  Future<void> startRealtime();
  Future<void> stopRealtime();
  Future<void> disposeRealtime();
}
