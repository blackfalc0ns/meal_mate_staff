import '../models/realtime/driver_availability_updated_event_dto.dart';

abstract interface class DispatcherDriversStatusRealtimeClient {
  Stream<DriverAvailabilityUpdatedEventDto> get events;
  Future<void> acquire(String ownerId);
  Future<void> release(String ownerId);
  Future<void> dispose();
}
