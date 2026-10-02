import '../../domain/entities/driver_orders_realtime_event.dart';

abstract interface class DriverOrdersRealtimeClient {
  Stream<DriverOrdersRealtimeEvent> get events;
  Stream<bool> get connectionStatus;
  bool get isConnected;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();

  /// Invokes the `UpdateLocation` hub method to broadcast driver's coordinates.
  ///
  /// Rejects (0,0). Returns server acknowledgement map on success.
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  });
}
