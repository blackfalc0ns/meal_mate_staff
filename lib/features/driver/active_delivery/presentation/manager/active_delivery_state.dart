import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/entities/delivery_trip_status.dart';

class ActiveDeliveryState {
  const ActiveDeliveryState({
    required this.trip,
    this.isLoading = false,
    this.errorMessage,
  });

  final ActiveDeliveryTripEntity trip;
  final bool isLoading;
  final String? errorMessage;

  DeliveryTripStatus get status => trip.status;

  ActiveDeliveryState copyWith({
    ActiveDeliveryTripEntity? trip,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ActiveDeliveryState(
      trip: trip ?? this.trip,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
