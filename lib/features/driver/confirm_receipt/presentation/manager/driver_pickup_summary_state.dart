import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_pickup_summary_entity.dart';
import '../../domain/entities/driver_trip_start_entity.dart';

class DriverPickupSummaryState {
  const DriverPickupSummaryState({
    this.tripId,
    this.summary,
    this.isInitialLoading = false,
    this.isActionLoading = false,
    this.failure,
    this.startTripResult,
    this.idempotencyKey,
  });

  final String? tripId;
  final DriverPickupSummaryEntity? summary;
  final bool isInitialLoading;
  final bool isActionLoading;
  final Failure? failure;
  final DriverTripStartEntity? startTripResult;
  final String? idempotencyKey;

  bool get hasLoadedOnce => summary != null;

  bool get canStartTrip =>
      (summary?.canStartTrip ?? false) && !isActionLoading && !isInitialLoading;

  DriverPickupSummaryState copyWith({
    String? tripId,
    DriverPickupSummaryEntity? summary,
    bool? isInitialLoading,
    bool? isActionLoading,
    Failure? failure,
    bool clearFailure = false,
    DriverTripStartEntity? startTripResult,
    String? idempotencyKey,
  }) {
    return DriverPickupSummaryState(
      tripId: tripId ?? this.tripId,
      summary: summary ?? this.summary,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      startTripResult: startTripResult ?? this.startTripResult,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}
