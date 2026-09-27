import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/location_exception.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../../../../../core/services/driver_pickup_location_provider.dart';
import '../../../../../core/services/idempotency_key_factory.dart';
import '../../domain/entities/start_driver_trip_request_entity.dart';
import '../../domain/usecase/get_driver_pickup_summary_usecase.dart';
import '../../domain/usecase/start_driver_trip_usecase.dart';
import 'driver_pickup_summary_event.dart';
import 'driver_pickup_summary_state.dart';

@injectable
class DriverPickupSummaryViewModel
    extends Bloc<DriverPickupSummaryEvent, DriverPickupSummaryState> {
  DriverPickupSummaryViewModel({
    required GetDriverPickupSummaryUseCase getSummaryUseCase,
    required StartDriverTripUseCase startTripUseCase,
    required DriverPickupLocationProvider locationProvider,
    required IdempotencyKeyFactory idempotencyKeyFactory,
  }) : _getSummaryUseCase = getSummaryUseCase,
       _startTripUseCase = startTripUseCase,
       _locationProvider = locationProvider,
       _idempotencyKeyFactory = idempotencyKeyFactory,
       super(const DriverPickupSummaryState()) {
    on<LoadDriverPickupSummaryEvent>(_onLoadSummary);
    on<RetryDriverPickupSummaryEvent>(_onRetry);
    on<StartDriverTripEvent>(_onStartTrip);
  }

  final GetDriverPickupSummaryUseCase _getSummaryUseCase;
  final StartDriverTripUseCase _startTripUseCase;
  final DriverPickupLocationProvider _locationProvider;
  final IdempotencyKeyFactory _idempotencyKeyFactory;

  void doIntent(DriverPickupSummaryEvent event) => add(event);

  Future<void> _onLoadSummary(
    LoadDriverPickupSummaryEvent event,
    Emitter<DriverPickupSummaryState> emit,
  ) async {
    final tripId = event.tripId.trim();
    if (tripId.isEmpty) {
      emit(
        state.copyWith(
          failure: Failure(
            errorMessage: 'Trip ID cannot be empty',
            code: 'empty_trip_id',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        tripId: tripId,
        isInitialLoading: state.summary == null,
        clearFailure: true,
      ),
    );

    final result = await _getSummaryUseCase(tripId);

    if (emit.isDone) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            summary: data,
            isInitialLoading: false,
            clearFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isInitialLoading: false, failure: failure));
    }
  }

  Future<void> _onRetry(
    RetryDriverPickupSummaryEvent event,
    Emitter<DriverPickupSummaryState> emit,
  ) async {
    if (state.summary == null && state.tripId != null) {
      await _onLoadSummary(LoadDriverPickupSummaryEvent(state.tripId!), emit);
    } else {
      await _onStartTrip(const StartDriverTripEvent(), emit);
    }
  }

  Future<void> _onStartTrip(
    StartDriverTripEvent event,
    Emitter<DriverPickupSummaryState> emit,
  ) async {
    final effectiveTripId = state.tripId ?? state.summary?.tripId;
    if (effectiveTripId == null || effectiveTripId.isEmpty) {
      emit(
        state.copyWith(
          failure: Failure(
            errorMessage: 'Cannot start trip without a valid trip ID',
            code: 'missing_trip_id',
          ),
        ),
      );
      return;
    }

    // Reuse persistent idempotency key or create new one
    final idempotencyKey =
        state.idempotencyKey ?? _idempotencyKeyFactory.create();
    emit(state.copyWith(idempotencyKey: idempotencyKey, clearFailure: true));

    // Acquire GPS location
    DriverPickupCoordinates coordinates;
    try {
      coordinates = await _locationProvider.getCurrentCoordinates();
    } on LocationServiceException catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          failure: Failure(
            errorMessage: 'Location service error: ${e.type.name}',
            code: 'location_error',
          ),
        ),
      );
      return;
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          failure: Failure(errorMessage: e.toString(), code: 'location_error'),
        ),
      );
      return;
    }

    emit(state.copyWith(isActionLoading: true, clearFailure: true));

    final result = await _startTripUseCase(
      tripId: effectiveTripId,
      idempotencyKey: idempotencyKey,
      request: StartDriverTripRequestEntity(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      ),
    );

    if (emit.isDone) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isActionLoading: false,
            startTripResult: data,
            clearFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isActionLoading: false, failure: failure));
    }
  }
}
