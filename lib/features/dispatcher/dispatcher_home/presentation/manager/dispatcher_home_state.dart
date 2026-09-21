import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import '../../domain/entities/dispatcher_home_overview_entity.dart';

const _unchanged = Object();

class DispatcherHomeState {
  const DispatcherHomeState({
    this.overview,
    this.liveDrivers = const [],
    this.isOverviewLoading = false,
    this.isLiveDriversLoading = false,
    this.overviewFailure,
    this.liveDriversFailure,
    this.hasLoadedOnce = false,
  });

  final DispatcherHomeOverviewEntity? overview;
  final List<DispatcherHomeMapDriverPinEntity> liveDrivers;
  final bool isOverviewLoading;
  final bool isLiveDriversLoading;
  final Failure? overviewFailure;
  final Failure? liveDriversFailure;
  final bool hasLoadedOnce;

  bool get hasOverview => overview != null;

  DispatcherHomeState copyWith({
    Object? overview = _unchanged,
    List<DispatcherHomeMapDriverPinEntity>? liveDrivers,
    bool? isOverviewLoading,
    bool? isLiveDriversLoading,
    Object? overviewFailure = _unchanged,
    Object? liveDriversFailure = _unchanged,
    bool? hasLoadedOnce,
  }) {
    return DispatcherHomeState(
      overview: identical(overview, _unchanged)
          ? this.overview
          : overview as DispatcherHomeOverviewEntity?,
      liveDrivers: liveDrivers ?? this.liveDrivers,
      isOverviewLoading: isOverviewLoading ?? this.isOverviewLoading,
      isLiveDriversLoading: isLiveDriversLoading ?? this.isLiveDriversLoading,
      overviewFailure: identical(overviewFailure, _unchanged)
          ? this.overviewFailure
          : overviewFailure as Failure?,
      liveDriversFailure: identical(liveDriversFailure, _unchanged)
          ? this.liveDriversFailure
          : liveDriversFailure as Failure?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
