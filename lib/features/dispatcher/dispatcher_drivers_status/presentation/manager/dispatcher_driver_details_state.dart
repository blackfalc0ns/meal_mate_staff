import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_driver_details_entity.dart';

class DispatcherDriverDetailsState {
  const DispatcherDriverDetailsState({
    required this.driverId,
    this.details,
    this.failure,
    this.inlineFailure,
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.isUpdatingAvailability = false,
  });

  final String driverId;
  final DispatcherDriverDetailsEntity? details;
  final Failure? failure;
  final Failure? inlineFailure;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isUpdatingAvailability;

  bool get isLoading => isInitialLoading || isRefreshing;
  bool get hasContent => details != null;

  DispatcherDriverDetailsState copyWith({
    String? driverId,
    DispatcherDriverDetailsEntity? details,
    Failure? failure,
    bool clearFailure = false,
    Failure? inlineFailure,
    bool clearInlineFailure = false,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isUpdatingAvailability,
  }) {
    return DispatcherDriverDetailsState(
      driverId: driverId ?? this.driverId,
      details: details ?? this.details,
      failure: clearFailure ? null : (failure ?? this.failure),
      inlineFailure: clearInlineFailure
          ? null
          : (inlineFailure ?? this.inlineFailure),
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isUpdatingAvailability:
          isUpdatingAvailability ?? this.isUpdatingAvailability,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverDetailsState &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          details == other.details &&
          failure == other.failure &&
          inlineFailure == other.inlineFailure &&
          isInitialLoading == other.isInitialLoading &&
          isRefreshing == other.isRefreshing &&
          isUpdatingAvailability == other.isUpdatingAvailability;

  @override
  int get hashCode => Object.hash(
    driverId,
    details,
    failure,
    inlineFailure,
    isInitialLoading,
    isRefreshing,
    isUpdatingAvailability,
  );
}
