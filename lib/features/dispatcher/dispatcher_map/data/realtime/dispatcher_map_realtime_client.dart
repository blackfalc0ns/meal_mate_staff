import '../../domain/entities/dispatcher_map_connection_status.dart';
import 'dispatcher_map_realtime_event_dto.dart';

abstract interface class DispatcherMapRealtimeClient {
  Stream<DispatcherMapRealtimeEventDto> get events;
  Stream<DispatcherMapConnectionStatus> get connectionStatuses;

  Future<void> acquire(String ownerId);
  Future<void> release(String ownerId);

  Future<void> connect();
  Future<void> disconnect();
  Future<void> dispose();
}
