import '../entities/active_delivery_location_entity.dart';
import '../entities/active_delivery_trip_entity.dart';

abstract class ActiveDeliveryRepository {
  Future<ActiveDeliveryTripEntity> getActiveTrip();
  Stream<ActiveDeliveryLocationEntity> watchDriverLocation();
  Future<void> startDeliveryRoute(String tripId);
  Future<void> markArrivedAtCustomer(String tripId);
  Future<void> completeDelivery(String tripId);
  Future<void> reportDeliveryDelay(String tripId, String reason);
  Future<void> reportDeliveryFailed(
    String tripId,
    String reasonId,
    String? note,
  );
  Future<void> confirmBoxReturnedToRestaurant(String tripId);
  void dispose();
}
