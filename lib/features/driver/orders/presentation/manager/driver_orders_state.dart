import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_delivery_manifest_entity.dart';
import '../../domain/entities/driver_orders_query_entity.dart';

class DriverOrdersState {
  const DriverOrdersState({
    required this.manifest,
    this.query = const DriverOrdersQueryEntity(),
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isQueryLoading = false,
    this.failure,
    this.actionFailure,
    this.isRealtimeConnected = false,
    this.lastAppliedEventAtUtc,
    this.hasLoadedOnce = false,
  });

  const DriverOrdersState.initial()
    : manifest = const DriverDeliveryManifestEntity.empty(),
      query = const DriverOrdersQueryEntity(),
      isInitialLoading = true,
      isRefreshing = false,
      isQueryLoading = false,
      failure = null,
      actionFailure = null,
      isRealtimeConnected = false,
      lastAppliedEventAtUtc = null,
      hasLoadedOnce = false;

  final DriverDeliveryManifestEntity manifest;
  final DriverOrdersQueryEntity query;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isQueryLoading;
  final Failure? failure;
  final Failure? actionFailure;
  final bool isRealtimeConnected;
  final DateTime? lastAppliedEventAtUtc;
  final bool hasLoadedOnce;

  DriverOrdersState copyWith({
    DriverDeliveryManifestEntity? manifest,
    DriverOrdersQueryEntity? query,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isQueryLoading,
    Failure? failure,
    bool clearFailure = false,
    Failure? actionFailure,
    bool clearActionFailure = false,
    bool? isRealtimeConnected,
    DateTime? lastAppliedEventAtUtc,
    bool? hasLoadedOnce,
  }) {
    return DriverOrdersState(
      manifest: manifest ?? this.manifest,
      query: query ?? this.query,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isQueryLoading: isQueryLoading ?? this.isQueryLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
      isRealtimeConnected: isRealtimeConnected ?? this.isRealtimeConnected,
      lastAppliedEventAtUtc:
          lastAppliedEventAtUtc ?? this.lastAppliedEventAtUtc,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
