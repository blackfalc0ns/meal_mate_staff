import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../../domain/repositories/active_delivery_repository.dart';
import 'active_delivery_state.dart';

class ActiveDeliveryViewModel extends Cubit<ActiveDeliveryState> {
  ActiveDeliveryViewModel({
    required this.repository,
    ActiveDeliveryTripEntity? initialTrip,
  }) : super(
         ActiveDeliveryState(
           trip: initialTrip ?? DriverActiveDeliveryFakeData.defaultTrip,
         ),
       );

  final ActiveDeliveryRepository repository;

  Future<void> loadTrip() async {
    emit(state.copyWith(isLoading: true));
    try {
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> startRoute() async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.startDeliveryRoute(state.trip.tripId);
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> markArrived() async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.markArrivedAtCustomer(state.trip.tripId);
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> completeDelivery() async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.completeDelivery(state.trip.tripId);
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> reportDelay(String reason) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.reportDeliveryDelay(state.trip.tripId, reason);
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> reportFailure(String reasonId, String? note) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.reportDeliveryFailed(state.trip.tripId, reasonId, note);
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> confirmBoxReturned() async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.confirmBoxReturnedToRestaurant(state.trip.tripId);
      final trip = await repository.getActiveTrip();
      emit(state.copyWith(trip: trip, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
