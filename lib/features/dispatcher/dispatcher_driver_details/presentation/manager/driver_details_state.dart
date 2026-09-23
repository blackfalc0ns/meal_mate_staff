import '../../../../../core/network/failures.dart';
import '../../../dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/driver_active_box_entity.dart';
import '../../domain/entities/driver_current_location_entity.dart';
import '../../domain/entities/driver_details_entity.dart';

class DriverDetailsState {
  const DriverDetailsState({
    this.details,
    this.activeBoxes,
    this.location,
    this.isProfileLoading = false,
    this.isBoxesLoading = false,
    this.isLocationLoading = false,
    this.isRefreshing = false,
    this.isReconciling = false,
    this.profileFailure,
    this.boxesFailure,
    this.locationFailure,
    this.connectionStatus = DispatcherMapConnectionStatus.disconnected,
    this.noticeId = 0,
    this.noticeFailure,
  });

  final DriverDetailsEntity? details;
  final List<DriverActiveBoxEntity>? activeBoxes;
  final DriverCurrentLocationEntity? location;

  final bool isProfileLoading;
  final bool isBoxesLoading;
  final bool isLocationLoading;
  final bool isRefreshing;
  final bool isReconciling;

  final Failure? profileFailure;
  final Failure? boxesFailure;
  final Failure? locationFailure;

  final DispatcherMapConnectionStatus connectionStatus;
  final int noticeId;
  final Failure? noticeFailure;

  bool get hasProfile => details != null;
  bool get hasBoxes => activeBoxes != null;
  bool get hasLocation => location != null;

  bool get isInitialLoading =>
      (details == null && profileFailure == null && isProfileLoading) ||
      (activeBoxes == null && boxesFailure == null && isBoxesLoading) ||
      (location == null && locationFailure == null && isLocationLoading);

  DriverDetailsState copyWith({
    DriverDetailsEntity? details,
    List<DriverActiveBoxEntity>? activeBoxes,
    DriverCurrentLocationEntity? location,
    bool? isProfileLoading,
    bool? isBoxesLoading,
    bool? isLocationLoading,
    bool? isRefreshing,
    bool? isReconciling,
    Failure? profileFailure,
    bool clearProfileFailure = false,
    Failure? boxesFailure,
    bool clearBoxesFailure = false,
    Failure? locationFailure,
    bool clearLocationFailure = false,
    DispatcherMapConnectionStatus? connectionStatus,
    int? noticeId,
    Failure? noticeFailure,
    bool clearNoticeFailure = false,
  }) {
    return DriverDetailsState(
      details: details ?? this.details,
      activeBoxes: activeBoxes ?? this.activeBoxes,
      location: location ?? this.location,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      isBoxesLoading: isBoxesLoading ?? this.isBoxesLoading,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isReconciling: isReconciling ?? this.isReconciling,
      profileFailure: clearProfileFailure
          ? null
          : (profileFailure ?? this.profileFailure),
      boxesFailure:
          clearBoxesFailure ? null : (boxesFailure ?? this.boxesFailure),
      locationFailure: clearLocationFailure
          ? null
          : (locationFailure ?? this.locationFailure),
      connectionStatus: connectionStatus ?? this.connectionStatus,
      noticeId: noticeId ?? this.noticeId,
      noticeFailure:
          clearNoticeFailure ? null : (noticeFailure ?? this.noticeFailure),
    );
  }
}
