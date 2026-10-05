import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../domain/entities/driver_map_navigation_entity.dart';
import '../../domain/entities/driver_map_route_entity.dart';
import '../../domain/entities/driver_map_stop_entity.dart';
import '../../../tracking/domain/entities/driver_live_location_sample.dart';

class DriverMapState {
  const DriverMapState({
    this.route,
    this.selectedStopId,
    this.visibleNavigation,
    this.liveLocation,
    this.failure,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isEmpty = false,
    this.isActive = false,
    this.isForeground = true,
  });

  final DriverMapRouteEntity? route;
  final String? selectedStopId;
  final DriverMapNavigationEntity? visibleNavigation;
  final DriverLiveLocationSample? liveLocation;
  final Failure? failure;
  final bool isLoading;
  final bool isRefreshing;
  final bool isEmpty;
  final bool isActive;
  final bool isForeground;

  DriverMapStopEntity? get selectedStop {
    if (selectedStopId == null || route == null) return null;
    return route!.stops.cast<DriverMapStopEntity?>().firstWhere(
          (s) => s?.id == selectedStopId,
          orElse: () => null,
        );
  }

  DriverMapState copyWith({
    DriverMapRouteEntity? route,
    bool clearRoute = false,
    String? selectedStopId,
    bool clearSelectedStopId = false,
    DriverMapNavigationEntity? visibleNavigation,
    bool clearVisibleNavigation = false,
    DriverLiveLocationSample? liveLocation,
    bool clearLiveLocation = false,
    Failure? failure,
    bool clearFailure = false,
    bool? isLoading,
    bool? isRefreshing,
    bool? isEmpty,
    bool? isActive,
    bool? isForeground,
  }) {
    return DriverMapState(
      route: clearRoute ? null : (route ?? this.route),
      selectedStopId: clearSelectedStopId ? null : (selectedStopId ?? this.selectedStopId),
      visibleNavigation: clearVisibleNavigation ? null : (visibleNavigation ?? this.visibleNavigation),
      liveLocation: clearLiveLocation ? null : (liveLocation ?? this.liveLocation),
      failure: clearFailure ? null : (failure ?? this.failure),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isEmpty: isEmpty ?? this.isEmpty,
      isActive: isActive ?? this.isActive,
      isForeground: isForeground ?? this.isForeground,
    );
  }
}
