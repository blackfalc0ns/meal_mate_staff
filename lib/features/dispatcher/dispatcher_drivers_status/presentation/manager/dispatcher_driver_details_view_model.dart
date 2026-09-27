import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/update_driver_availability_request_entity.dart';
import '../../domain/entities/update_driver_availability_result_entity.dart';
import '../../domain/usecase/get_dispatcher_driver_details_usecase.dart';
import '../../domain/usecase/observe_dispatcher_driver_availability_usecase.dart';
import '../../domain/usecase/start_dispatcher_drivers_status_updates_usecase.dart';
import '../../domain/usecase/stop_dispatcher_drivers_status_updates_usecase.dart';
import '../../domain/usecase/toggle_driver_availability_usecase.dart';
import 'dispatcher_driver_details_event.dart';
import 'dispatcher_driver_details_state.dart';

@injectable
class DispatcherDriverDetailsViewModel
    extends Cubit<DispatcherDriverDetailsState> {
  DispatcherDriverDetailsViewModel({
    @factoryParam required String driverId,
    required this.getDriverDetailsUseCase,
    required this.toggleDriverAvailabilityUseCase,
    this.observeDriverAvailabilityUseCase,
    this.startUpdatesUseCase,
    this.stopUpdatesUseCase,
  }) : super(DispatcherDriverDetailsState(driverId: driverId));

  final GetDispatcherDriverDetailsUseCase getDriverDetailsUseCase;
  final ToggleDriverAvailabilityUseCase toggleDriverAvailabilityUseCase;
  final ObserveDispatcherDriverAvailabilityUseCase?
  observeDriverAvailabilityUseCase;
  final StartDispatcherDriversStatusUpdatesUseCase? startUpdatesUseCase;
  final StopDispatcherDriversStatusUpdatesUseCase? stopUpdatesUseCase;

  String get _realtimeOwnerId => 'dispatcher-driver-details-${state.driverId}';
  StreamSubscription<UpdateDriverAvailabilityResultEntity>?
  _realtimeSubscription;
  bool _realtimeAcquired = false;

  void _initRealtime() {
    if (_realtimeAcquired || state.driverId.trim().isEmpty) return;
    _realtimeAcquired = true;
    unawaited(startUpdatesUseCase?.call(_realtimeOwnerId));
    _realtimeSubscription = observeDriverAvailabilityUseCase
        ?.call(state.driverId)
        .listen((update) {
          unawaited(doIntent(RealtimeAvailabilityReceived(update)));
        });
  }

  Future<void> doIntent(DispatcherDriverDetailsEvent event) async {
    switch (event) {
      case Started(:final driverId):
        if (state.driverId != driverId) {
          emit(state.copyWith(driverId: driverId));
        }
        _initRealtime();
        await _loadDetails();

      case Refreshed():
        await _loadDetails(isRefreshing: true);

      case RetryRequested():
        await _loadDetails();

      case AvailabilityChanged(:final isAvailable, :final reason):
        await _toggleAvailability(isAvailable, reason: reason);

      case RealtimeAvailabilityReceived(:final update):
        _onRealtimeReceived(update);

      case ClearInlineFailure():
        emit(state.copyWith(clearInlineFailure: true));
    }
  }

  Future<void> _loadDetails({bool isRefreshing = false}) async {
    final isInitial = state.details == null && !isRefreshing;

    emit(
      state.copyWith(
        isInitialLoading: isInitial,
        isRefreshing: isRefreshing,
        clearFailure: isInitial,
        clearInlineFailure: true,
      ),
    );

    final result = await getDriverDetailsUseCase(state.driverId);

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            details: data,
            isInitialLoading: false,
            isRefreshing: false,
            clearFailure: true,
            clearInlineFailure: true,
          ),
        );

      case ApiErrorResult(:final failure):
        if (state.details == null) {
          emit(
            state.copyWith(
              failure: failure,
              isInitialLoading: false,
              isRefreshing: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              inlineFailure: failure,
              isInitialLoading: false,
              isRefreshing: false,
            ),
          );
        }
    }
  }

  Future<void> _toggleAvailability(
    bool requestedAvailability, {
    String? reason,
  }) async {
    if (state.isUpdatingAvailability || state.details == null) return;

    final previousDetails = state.details!;

    final optimisticStatus =
        previousDetails.operationalStatus ==
            DispatcherDriverStatusType.inDelivery
        ? DispatcherDriverStatusType.inDelivery
        : requestedAvailability
        ? DispatcherDriverStatusType.available
        : DispatcherDriverStatusType.unavailable;

    final optimisticDetails = previousDetails.copyWith(
      isAvailable: requestedAvailability,
      operationalStatus: optimisticStatus,
      isOnline:
          optimisticStatus != DispatcherDriverStatusType.unavailable &&
          optimisticStatus != DispatcherDriverStatusType.unknown,
    );

    emit(
      state.copyWith(
        details: optimisticDetails,
        isUpdatingAvailability: true,
        clearInlineFailure: true,
      ),
    );

    final result = await toggleDriverAvailabilityUseCase(
      request: UpdateDriverAvailabilityRequestEntity(
        driverId: state.driverId,
        isAvailable: requestedAvailability,
        reason: reason,
      ),
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        final reconciledDetails = state.details?.copyWith(
          isAvailable: data.isAvailable,
          operationalStatus: data.operationalStatus,
          isOnline:
              data.operationalStatus !=
                  DispatcherDriverStatusType.unavailable &&
              data.operationalStatus != DispatcherDriverStatusType.unknown,
        );
        emit(
          state.copyWith(
            details: reconciledDetails,
            isUpdatingAvailability: false,
          ),
        );

      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            details: previousDetails,
            isUpdatingAvailability: false,
            inlineFailure: failure,
          ),
        );
    }
  }

  void _onRealtimeReceived(UpdateDriverAvailabilityResultEntity update) {
    if (update.driverId != state.driverId || state.details == null) return;

    final reconciledDetails = state.details!.copyWith(
      isAvailable: update.isAvailable,
      operationalStatus: update.operationalStatus,
      isOnline:
          update.operationalStatus != DispatcherDriverStatusType.unavailable &&
          update.operationalStatus != DispatcherDriverStatusType.unknown,
    );

    emit(state.copyWith(details: reconciledDetails));
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    if (_realtimeAcquired) {
      await stopUpdatesUseCase?.call(_realtimeOwnerId);
    }
    return super.close();
  }
}
