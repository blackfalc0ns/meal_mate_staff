import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import '../../../dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import '../../domain/entities/driver_current_location_entity.dart';
import '../../domain/entities/driver_details_entity.dart';
import '../../domain/entities/driver_details_status.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/usecase/acquire_driver_details_realtime_usecase.dart';
import '../../domain/usecase/get_driver_active_boxes_usecase.dart';
import '../../domain/usecase/get_driver_current_location_usecase.dart';
import '../../domain/usecase/get_driver_details_usecase.dart';
import '../../domain/usecase/observe_driver_details_updates_usecase.dart';
import '../../domain/usecase/release_driver_details_realtime_usecase.dart';
import 'driver_details_event.dart';
import 'driver_details_state.dart';

@injectable
class DriverDetailsViewModel extends Cubit<DriverDetailsState> {
  DriverDetailsViewModel(
    @factoryParam this.driverId,
    this._getDriverDetailsUseCase,
    this._getDriverActiveBoxesUseCase,
    this._getDriverCurrentLocationUseCase,
    this._observeUpdatesUseCase,
    this._acquireRealtimeUseCase,
    this._releaseRealtimeUseCase,
  ) : super(const DriverDetailsState());

  final String driverId;
  final GetDriverDetailsUseCase _getDriverDetailsUseCase;
  final GetDriverActiveBoxesUseCase _getDriverActiveBoxesUseCase;
  final GetDriverCurrentLocationUseCase _getDriverCurrentLocationUseCase;
  final ObserveDriverDetailsUpdatesUseCase _observeUpdatesUseCase;
  final AcquireDriverDetailsRealtimeUseCase _acquireRealtimeUseCase;
  final ReleaseDriverDetailsRealtimeUseCase _releaseRealtimeUseCase;

  StreamSubscription<DispatcherMapRealtimeEvent>? _eventsSubscription;
  StreamSubscription<DispatcherMapConnectionStatus>? _statusSubscription;

  int _loadGeneration = 0;
  bool _isRealtimeAcquired = false;
  bool _isReconciling = false;
  bool _reconcileAgain = false;

  void _ensureRealtimeSubscribed() {
    if (_eventsSubscription != null) return;
    _eventsSubscription = _observeUpdatesUseCase.events.listen((event) {
      doIntent(RealtimeDriverDetailsEventReceived(event));
    });
    _statusSubscription = _observeUpdatesUseCase.connectionStatuses.listen((
      status,
    ) {
      doIntent(DriverDetailsConnectionStatusReceived(status));
    });
  }

  Future<void> doIntent(DriverDetailsEvent event) async {
    if (isClosed) return;

    switch (event) {
      case LoadDriverDetailsEvent():
        await _handleLoad(isRefresh: false);
      case RefreshDriverDetailsEvent():
        await _handleLoad(isRefresh: true);
      case RetryDriverProfileEvent():
        await _handleRetryProfile();
      case RetryDriverBoxesEvent():
        await _handleRetryBoxes();
      case RetryDriverLocationEvent():
        await _handleRetryLocation();
      case RealtimeDriverDetailsEventReceived(:final event):
        _handleRealtimeEvent(event);
      case DriverDetailsConnectionStatusReceived(:final status):
        await _handleConnectionStatus(status);
      case DriverDetailsLifecycleResumed():
        await _handleResumed();
      case DriverDetailsLifecyclePaused():
        await _handlePaused();
    }
  }

  Future<void> _handleLoad({required bool isRefresh}) async {
    final gen = ++_loadGeneration;
    _ensureRealtimeSubscribed();

    if (!_isRealtimeAcquired) {
      _isRealtimeAcquired = true;
      unawaited(_acquireRealtimeUseCase(driverId));
    }

    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true));
    } else {
      emit(
        state.copyWith(
          isProfileLoading: state.details == null,
          isBoxesLoading: state.activeBoxes == null,
          isLocationLoading: state.location == null,
          clearProfileFailure: true,
          clearBoxesFailure: true,
          clearLocationFailure: true,
        ),
      );
    }

    final pFuture = _fetchProfile(gen, isRefresh: isRefresh);
    final bFuture = _fetchBoxes(gen, isRefresh: isRefresh);
    final lFuture = _fetchLocation(gen, isRefresh: isRefresh);

    await Future.wait([pFuture, bFuture, lFuture]);

    if (!isClosed && gen == _loadGeneration && isRefresh) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> _handleRetryProfile() async {
    final gen = ++_loadGeneration;
    emit(state.copyWith(isProfileLoading: true, clearProfileFailure: true));

    final futures = <Future<void>>[_fetchProfile(gen, isRefresh: false)];

    if (state.activeBoxes == null) {
      emit(state.copyWith(isBoxesLoading: true, clearBoxesFailure: true));
      futures.add(_fetchBoxes(gen, isRefresh: false));
    }
    if (state.location == null) {
      emit(state.copyWith(isLocationLoading: true, clearLocationFailure: true));
      futures.add(_fetchLocation(gen, isRefresh: false));
    }

    await Future.wait(futures);
  }

  Future<void> _handleRetryBoxes() async {
    final gen = ++_loadGeneration;
    emit(state.copyWith(isBoxesLoading: true, clearBoxesFailure: true));
    await _fetchBoxes(gen, isRefresh: false);
  }

  Future<void> _handleRetryLocation() async {
    final gen = ++_loadGeneration;
    emit(state.copyWith(isLocationLoading: true, clearLocationFailure: true));
    await _fetchLocation(gen, isRefresh: false);
  }

  Future<void> _fetchProfile(int gen, {required bool isRefresh}) async {
    final result = await _getDriverDetailsUseCase(driverId);
    if (isClosed || gen != _loadGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            details: data,
            isProfileLoading: false,
            clearProfileFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        if (state.details != null) {
          emit(
            state.copyWith(
              isProfileLoading: false,
              noticeId: state.noticeId + 1,
              noticeFailure: failure,
            ),
          );
        } else {
          emit(
            state.copyWith(isProfileLoading: false, profileFailure: failure),
          );
        }
    }
  }

  Future<void> _fetchBoxes(int gen, {required bool isRefresh}) async {
    final result = await _getDriverActiveBoxesUseCase(driverId);
    if (isClosed || gen != _loadGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            activeBoxes: data,
            isBoxesLoading: false,
            clearBoxesFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        if (state.activeBoxes != null) {
          emit(
            state.copyWith(
              isBoxesLoading: false,
              noticeId: state.noticeId + 1,
              noticeFailure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isBoxesLoading: false, boxesFailure: failure));
        }
    }
  }

  Future<void> _fetchLocation(int gen, {required bool isRefresh}) async {
    final result = await _getDriverCurrentLocationUseCase(driverId);
    if (isClosed || gen != _loadGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            location: data,
            isLocationLoading: false,
            clearLocationFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        if (state.location != null) {
          emit(
            state.copyWith(
              isLocationLoading: false,
              noticeId: state.noticeId + 1,
              noticeFailure: failure,
            ),
          );
        } else {
          emit(
            state.copyWith(isLocationLoading: false, locationFailure: failure),
          );
        }
    }
  }

  void _handleRealtimeEvent(DispatcherMapRealtimeEvent event) {
    switch (event) {
      case DriverLocationUpdated():
        if (event.driverId != driverId) return;
        if (event.latitude < -90.0 ||
            event.latitude > 90.0 ||
            event.longitude < -180.0 ||
            event.longitude > 180.0) {
          return;
        }

        final currentLoc = state.location;
        final updatedLocation = currentLoc != null
            ? DriverCurrentLocationEntity(
                latitude: event.latitude,
                longitude: event.longitude,
                heading: event.heading ?? currentLoc.heading,
                speed: event.speed ?? currentLoc.speed,
                destinationLatitude: currentLoc.destinationLatitude,
                destinationLongitude: currentLoc.destinationLongitude,
                statusBadgeText: currentLoc.statusBadgeText,
                timeAgoText: 'الآن',
                streetName: currentLoc.streetName,
                areaName: currentLoc.areaName,
                routePoints: currentLoc.routePoints,
                recordedAt: event.timestamp.toIso8601String(),
              )
            : DriverCurrentLocationEntity(
                latitude: event.latitude,
                longitude: event.longitude,
                heading: event.heading,
                speed: event.speed,
                statusBadgeText: 'مباشر',
                timeAgoText: 'الآن',
                streetName: '',
                areaName: '',
                recordedAt: event.timestamp.toIso8601String(),
              );
        emit(state.copyWith(location: updatedLocation));

      case DriverStatusUpdated():
        if (event.driverId != driverId) return;

        final currentDetails = state.details;
        if (currentDetails != null) {
          final domainStatus = DriverDetailsStatusX.fromApi(event.status.name);
          final updatedProfile = DriverProfileEntity(
            driverId: currentDetails.driver.driverId,
            driverCode: currentDetails.driver.driverCode,
            fullName: currentDetails.driver.fullName,
            phoneNumber: currentDetails.driver.phoneNumber,
            avatarUrl: currentDetails.driver.avatarUrl,
            status: domainStatus != DriverDetailsStatus.unknown
                ? domainStatus
                : currentDetails.driver.status,
            statusText: event.statusText ?? currentDetails.driver.statusText,
            statusDotColor:
                event.statusColor ?? currentDetails.driver.statusDotColor,
            lastUpdatedText: 'الآن',
          );
          emit(
            state.copyWith(
              details: DriverDetailsEntity(
                driver: updatedProfile,
                kpis: currentDetails.kpis,
                dailySummary: currentDetails.dailySummary,
              ),
            ),
          );
        }

        unawaited(_reconcile());

      case DriverBoxAssigned():
        if (event.driverId != driverId) return;
        unawaited(_reconcile());

      case DriverIssueUpdated():
        if (event.driverId != driverId) return;
    }
  }

  Future<void> _reconcile() async {
    if (_isReconciling) {
      _reconcileAgain = true;
      return;
    }
    _isReconciling = true;
    emit(state.copyWith(isReconciling: true));

    try {
      do {
        _reconcileAgain = false;
        final gen = _loadGeneration;
        await Future.wait([
          _fetchProfile(gen, isRefresh: true),
          _fetchBoxes(gen, isRefresh: true),
        ]);
      } while (_reconcileAgain && !isClosed);
    } finally {
      _isReconciling = false;
      if (!isClosed) {
        emit(state.copyWith(isReconciling: false));
      }
    }
  }

  Future<void> _handleConnectionStatus(
    DispatcherMapConnectionStatus status,
  ) async {
    final previousStatus = state.connectionStatus;
    emit(state.copyWith(connectionStatus: status));

    if (status == DispatcherMapConnectionStatus.connected &&
        previousStatus != DispatcherMapConnectionStatus.connected &&
        state.hasProfile) {
      await _handleLoad(isRefresh: true);
    }
  }

  Future<void> _handlePaused() async {
    if (_isRealtimeAcquired) {
      _isRealtimeAcquired = false;
      await _releaseRealtimeUseCase(driverId);
    }
  }

  Future<void> _handleResumed() async {
    if (!_isRealtimeAcquired) {
      _isRealtimeAcquired = true;
      await _acquireRealtimeUseCase(driverId);
      await _handleLoad(isRefresh: true);
    }
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await _statusSubscription?.cancel();
    if (_isRealtimeAcquired) {
      _isRealtimeAcquired = false;
      await _releaseRealtimeUseCase(driverId);
    }
    return super.close();
  }
}
