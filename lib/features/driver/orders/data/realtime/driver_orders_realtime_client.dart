import '../../domain/entities/driver_orders_realtime_event.dart';

abstract interface class DriverOrdersRealtimeClient {
  Stream<DriverOrdersRealtimeEvent> get events;
  Stream<bool> get connectionStatus;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}
