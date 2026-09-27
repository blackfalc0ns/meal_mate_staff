import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import '../../domain/entities/driver_pickup_manifest_entity.dart';

class DriverPickupManifestState {
  const DriverPickupManifestState({
    this.manifest,
    this.selectedFilter = DriverBoxesFilterType.all,
    this.isInitialLoading = true,
    this.isRefreshLoading = false,
    this.isFilterLoading = false,
    this.failure,
    this.hasLoadedOnce = false,
  });

  final DriverPickupManifestEntity? manifest;
  final DriverBoxesFilterType selectedFilter;
  final bool isInitialLoading;
  final bool isRefreshLoading;
  final bool isFilterLoading;
  final Failure? failure;
  final bool hasLoadedOnce;

  DriverPickupManifestState copyWith({
    DriverPickupManifestEntity? manifest,
    DriverBoxesFilterType? selectedFilter,
    bool? isInitialLoading,
    bool? isRefreshLoading,
    bool? isFilterLoading,
    Failure? failure,
    bool? hasLoadedOnce,
    bool clearFailure = false,
  }) {
    return DriverPickupManifestState(
      manifest: manifest ?? this.manifest,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshLoading: isRefreshLoading ?? this.isRefreshLoading,
      isFilterLoading: isFilterLoading ?? this.isFilterLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
