import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../data/realtime/driver_orders_realtime_client.dart';
import '../../domain/entities/driver_delivery_status.dart';
import '../../domain/entities/driver_delivery_stop_entity.dart';
import '../../domain/entities/driver_orders_filter.dart';
import '../../domain/entities/driver_orders_query_entity.dart';
import '../../domain/entities/driver_orders_realtime_event.dart';
import '../../domain/usecase/get_driver_orders_usecase.dart';
import '../../domain/usecase/observe_driver_orders_updates_usecase.dart';
import '../../domain/usecase/start_driver_orders_updates_usecase.dart';
import '../../domain/usecase/stop_driver_orders_updates_usecase.dart';
import 'driver_orders_event.dart';
import 'driver_orders_state.dart';

@injectable
class DriverOrdersViewModel extends Bloc<DriverOrdersEvent, DriverOrdersState> {
  DriverOrdersViewModel({
    required GetDriverOrdersUseCase getOrdersUseCase,
    required ObserveDriverOrdersUpdatesUseCase observeUpdatesUseCase,
    required StartDriverOrdersUpdatesUseCase startUpdatesUseCase,
    required StopDriverOrdersUpdatesUseCase stopUpdatesUseCase,
    required DriverOrdersRealtimeClient realtimeClient,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _observeUpdatesUseCase = observeUpdatesUseCase,
        _startUpdatesUseCase = startUpdatesUseCase,
        _stopUpdatesUseCase = stopUpdatesUseCase,
        _realtimeClient = realtimeClient,
        super(const DriverOrdersState.initial()) {
    on<LoadDriverOrdersEvent>(_onLoadOrders);
    on<RefreshDriverOrdersEvent>(_onRefreshOrders);
    on<SearchDriverOrdersEvent>(_onSearchOrders);
    on<SelectDriverOrdersFilterEvent>(_onSelectFilter);
    on<ResetDriverOrdersQueryEvent>(_onResetQuery);
    on<StartDriverOrdersRealtimeEvent>(_onStartRealtime);
    on<StopDriverOrdersRealtimeEvent>(_onStopRealtime);
    on<DriverOrdersRealtimeReceivedEvent>(_onRealtimeReceived);
    on<DriverOrdersRealtimeStatusChangedEvent>(_onRealtimeStatusChanged);

    _initRealtimeListeners();
  }

  final GetDriverOrdersUseCase _getOrdersUseCase;
  final ObserveDriverOrdersUpdatesUseCase _observeUpdatesUseCase;
  final StartDriverOrdersUpdatesUseCase _startUpdatesUseCase;
  final StopDriverOrdersUpdatesUseCase _stopUpdatesUseCase;
  final DriverOrdersRealtimeClient _realtimeClient;

  Timer? _searchDebounceTimer;
  StreamSubscription<DriverOrdersRealtimeEvent>? _realtimeSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  int _requestGeneration = 0;
  Map<String, int> _boxIndex = {};

  void _initRealtimeListeners() {
    _realtimeSubscription = _observeUpdatesUseCase().listen((event) {
      if (!isClosed) {
        add(DriverOrdersRealtimeReceivedEvent(event));
      }
    });

    _connectionSubscription = _realtimeClient.connectionStatus.listen((status) {
      if (!isClosed) {
        add(DriverOrdersRealtimeStatusChangedEvent(status));
      }
    });
  }

  void _rebuildBoxIndex() {
    _boxIndex = {
      for (int i = 0; i < state.manifest.stops.length; i++)
        state.manifest.stops[i].boxId: i,
    };
  }

  Future<void> _onLoadOrders(
    LoadDriverOrdersEvent event,
    Emitter<DriverOrdersState> emit,
  ) async {
    final currentGen = ++_requestGeneration;

    emit(
      state.copyWith(
        isInitialLoading: !state.hasLoadedOnce,
        isQueryLoading: state.hasLoadedOnce,
        clearFailure: true,
        clearActionFailure: true,
      ),
    );

    final result = await _getOrdersUseCase(state.query);
    if (currentGen != _requestGeneration || isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            manifest: data,
            isInitialLoading: false,
            isQueryLoading: false,
            hasLoadedOnce: true,
            clearFailure: true,
          ),
        );
        _rebuildBoxIndex();
        add(const StartDriverOrdersRealtimeEvent());

      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitialLoading: false,
            isQueryLoading: false,
            failure: failure,
          ),
        );
    }
  }

  Future<void> _onRefreshOrders(
    RefreshDriverOrdersEvent event,
    Emitter<DriverOrdersState> emit,
  ) async {
    final currentGen = ++_requestGeneration;

    emit(
      state.copyWith(
        isRefreshing: true,
        clearActionFailure: true,
      ),
    );

    final result = await _getOrdersUseCase(state.query);
    if (currentGen != _requestGeneration || isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            manifest: data,
            isRefreshing: false,
            hasLoadedOnce: true,
            clearFailure: true,
            clearActionFailure: true,
          ),
        );
        _rebuildBoxIndex();

      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isRefreshing: false,
            actionFailure: failure,
          ),
        );
    }
  }

  void _onSearchOrders(
    SearchDriverOrdersEvent event,
    Emitter<DriverOrdersState> emit,
  ) {
    if (event.query == state.query.search) return;

    _searchDebounceTimer?.cancel();
    final updatedQuery = state.query.copyWith(search: event.query);
    emit(state.copyWith(query: updatedQuery));

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!isClosed) {
        add(const LoadDriverOrdersEvent());
      }
    });
  }

  void _onSelectFilter(
    SelectDriverOrdersFilterEvent event,
    Emitter<DriverOrdersState> emit,
  ) {
    if (event.filter == state.query.filter) return;

    final updatedQuery = state.query.copyWith(filter: event.filter);
    emit(state.copyWith(query: updatedQuery));
    add(const LoadDriverOrdersEvent());
  }

  void _onResetQuery(
    ResetDriverOrdersQueryEvent event,
    Emitter<DriverOrdersState> emit,
  ) {
    _searchDebounceTimer?.cancel();
    emit(state.copyWith(query: const DriverOrdersQueryEntity()));
    add(const LoadDriverOrdersEvent());
  }

  Future<void> _onStartRealtime(
    StartDriverOrdersRealtimeEvent event,
    Emitter<DriverOrdersState> emit,
  ) async {
    await _startUpdatesUseCase();
  }

  Future<void> _onStopRealtime(
    StopDriverOrdersRealtimeEvent event,
    Emitter<DriverOrdersState> emit,
  ) async {
    await _stopUpdatesUseCase();
  }

  void _onRealtimeStatusChanged(
    DriverOrdersRealtimeStatusChangedEvent event,
    Emitter<DriverOrdersState> emit,
  ) {
    emit(state.copyWith(isRealtimeConnected: event.isConnected));
  }

  void _onRealtimeReceived(
    DriverOrdersRealtimeReceivedEvent eventWrapper,
    Emitter<DriverOrdersState> emit,
  ) {
    final event = eventWrapper.event;

    // Deduplicate / reject stale events
    if (state.lastAppliedEventAtUtc != null &&
        event.occurredAtUtc.isBefore(state.lastAppliedEventAtUtc!)) {
      return;
    }

    if (event is DriverTripInTransitEvent) {
      final updatedManifest = state.manifest.copyWith(
        tripStatusText: event.tripStatusText,
      );
      emit(
        state.copyWith(
          manifest: updatedManifest,
          lastAppliedEventAtUtc: event.occurredAtUtc,
        ),
      );
      return;
    }

    String? targetBoxId;
    DriverDeliveryStatus? newStatus;
    String? statusText;
    DateTime? deliveredAtUtc;
    String? failureCategory;
    String? failureText;

    if (event is DriverOrderDeliveredEvent) {
      targetBoxId = event.boxId;
      newStatus = DriverDeliveryStatus.delivered;
      statusText = event.statusText;
      deliveredAtUtc = event.deliveredAtUtc;
    } else if (event is DriverDeliveryFailedEvent) {
      targetBoxId = event.boxId;
      newStatus = DriverDeliveryStatus.failed;
      statusText = event.statusText;
      failureCategory = event.failureReasonCategory;
      failureText = event.failureReasonText;
    } else if (event is DriverArrivedAtCustomerEvent) {
      targetBoxId = event.boxId;
      newStatus = DriverDeliveryStatus.arrivedAtCustomer;
      statusText = event.statusText;
    } else if (event is DriverReassignmentRequestedEvent) {
      targetBoxId = event.boxId;
      newStatus = DriverDeliveryStatus.reassignmentRequested;
      statusText = event.statusText;
      failureCategory = event.failureReasonCategory;
      failureText = event.failureReasonText;
    }

    if (targetBoxId == null || newStatus == null) return;

    final index = _boxIndex[targetBoxId];
    if (index == null || index < 0 || index >= state.manifest.stops.length) {
      // Box not found in current manifest -> trigger throttled refresh
      add(const RefreshDriverOrdersEvent());
      return;
    }

    final currentStop = state.manifest.stops[index];
    final oldStatus = currentStop.status;

    final updatedStop = currentStop.copyWith(
      status: newStatus,
      statusText: statusText ?? currentStop.statusText,
      deliveredAtUtc: deliveredAtUtc ?? currentStop.deliveredAtUtc,
      failureReasonCategory: failureCategory ?? currentStop.failureReasonCategory,
      failureReasonText: failureText ?? currentStop.failureReasonText,
    );

    // Update counts if status changed
    var inProgress = state.manifest.inProgressCount;
    var delivered = state.manifest.deliveredCount;
    var failed = state.manifest.failedCount;

    if (oldStatus != newStatus) {
      if (oldStatus == DriverDeliveryStatus.inProgress ||
          oldStatus == DriverDeliveryStatus.arrivedAtCustomer) {
        inProgress = (inProgress - 1).clamp(0, 999999);
      } else if (oldStatus == DriverDeliveryStatus.delivered) {
        delivered = (delivered - 1).clamp(0, 999999);
      } else if (oldStatus == DriverDeliveryStatus.failed ||
          oldStatus == DriverDeliveryStatus.reassignmentRequested) {
        failed = (failed - 1).clamp(0, 999999);
      }

      if (newStatus == DriverDeliveryStatus.inProgress ||
          newStatus == DriverDeliveryStatus.arrivedAtCustomer) {
        inProgress++;
      } else if (newStatus == DriverDeliveryStatus.delivered) {
        delivered++;
      } else if (newStatus == DriverDeliveryStatus.failed ||
          newStatus == DriverDeliveryStatus.reassignmentRequested) {
        failed++;
      }
    }

    final updatedStops =
        List<DriverDeliveryStopEntity>.from(state.manifest.stops);
    updatedStops[index] = updatedStop;

    final updatedManifest = state.manifest.copyWith(
      stops: updatedStops,
      inProgressCount: inProgress,
      deliveredCount: delivered,
      failedCount: failed,
    );

    emit(
      state.copyWith(
        manifest: updatedManifest,
        lastAppliedEventAtUtc: event.occurredAtUtc,
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    _realtimeSubscription?.cancel();
    _connectionSubscription?.cancel();
    _stopUpdatesUseCase();
    return super.close();
  }
}
