import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/arrive_at_driver_customer_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/deliver_driver_order_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/upload_driver_delivery_proof_usecase.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

import 'active_delivery_event.dart';
import 'active_delivery_state.dart';

@injectable
class ActiveDeliveryViewModel extends Cubit<ActiveDeliveryState> {
  ActiveDeliveryViewModel({
    required this.getDriverMapRouteUseCase,
    required this.arriveAtDriverCustomerUseCase,
    required this.uploadDriverDeliveryProofUseCase,
    required this.deliverDriverOrderUseCase,
  }) : super(const ActiveDeliveryState());

  final GetDriverMapRouteUseCase getDriverMapRouteUseCase;
  final ArriveAtDriverCustomerUseCase arriveAtDriverCustomerUseCase;
  final UploadDriverDeliveryProofUseCase uploadDriverDeliveryProofUseCase;
  final DeliverDriverOrderUseCase deliverDriverOrderUseCase;

  int _loadRequestId = 0;

  void doIntent(ActiveDeliveryEvent event) {
    switch (event) {
      case LoadActiveDeliveryEvent():
        unawaited(_onLoad(event));
      case RefreshActiveDeliveryEvent():
        unawaited(_onRefresh());
      case StartActiveDeliveryRouteEvent():
        _onStartRoute();
      case ConfirmCustomerArrivalEvent():
        unawaited(_onConfirmArrival(event));
      case DeliveryProofSelectedEvent():
        unawaited(_onProofSelected(event));
      case RetryDeliveryProofUploadEvent():
        unawaited(_onRetryUpload());
      case OptionalDeliveryOtpChangedEvent():
        _onOtpChanged(event);
      case ConfirmCustomerDeliveryEvent():
        unawaited(_onConfirmDelivery(event));
      case ReconcileActiveDeliveryEvent():
        unawaited(_onReconcile());
      case ClearActiveDeliveryNavigationEvent():
        _onClearNavigation();
      case ActiveDeliveryPausedEvent():
        _onPaused();
      case ActiveDeliveryResumedEvent():
        _onResumed();
    }
  }

  Future<void> _onLoad(LoadActiveDeliveryEvent event) async {
    final requestId = ++_loadRequestId;
    final isSwitchingStop = event.stopId != null && event.stopId != state.selectedStopId;

    emit(state.copyWith(
      isInitialLoading: state.route == null,
      isRefreshing: state.route != null,
      selectedStopId: event.stopId ?? state.selectedStopId,
      clearLoadFailure: true,
      // If switching to a different stop, reset stop-specific transaction state
      clearArrivalResult: isSwitchingStop,
      clearDeliveryResult: isSwitchingStop,
      clearLocalPhotoPath: isSwitchingStop,
      clearProofStorageKey: isSwitchingStop,
      clearUploadedPhotoRevision: isSwitchingStop,
      clearArrivalFailure: isSwitchingStop,
      clearUploadFailure: isSwitchingStop,
      clearDeliveryFailure: isSwitchingStop,
      photoRevision: isSwitchingStop ? state.photoRevision + 1 : state.photoRevision,
      otpInput: isSwitchingStop ? '' : state.otpInput,
    ));

    final result = await getDriverMapRouteUseCase(focusedStopId: event.stopId);
    if (isClosed || requestId != _loadRequestId) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        final eligible = data.focusedStop.status == DriverDeliveryStatus.inProgress ||
            data.stops.any((s) => s.status == DriverDeliveryStatus.inProgress);
        final empty = data.stops.isEmpty;

        emit(state.copyWith(
          route: data,
          isInitialLoading: false,
          isRefreshing: false,
          isEmpty: empty,
          isEligibleToStart: eligible,
          clearLoadFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          loadFailure: failure,
          isEmpty: failure.code == 'DriverTrip.NotFound',
        ));
    }
  }

  Future<void> _onRefresh() async {
    final requestId = ++_loadRequestId;
    emit(state.copyWith(
      isRefreshing: true,
      clearLoadFailure: true,
    ));

    final result = await getDriverMapRouteUseCase(focusedStopId: state.selectedStopId);
    if (isClosed || requestId != _loadRequestId) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        final eligible = data.focusedStop.status == DriverDeliveryStatus.inProgress ||
            data.stops.any((s) => s.status == DriverDeliveryStatus.inProgress);
        emit(state.copyWith(
          route: data,
          isRefreshing: false,
          isEmpty: data.stops.isEmpty,
          isEligibleToStart: eligible,
          clearLoadFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isRefreshing: false,
          loadFailure: state.route == null ? failure : state.loadFailure,
        ));
    }
  }

  void _onStartRoute() {
    final stop = state.selectedStop;
    if (stop == null) return;
    if (stop.status == DriverDeliveryStatus.delivered) return;

    emit(state.copyWith(
      isEligibleToStart: true,
      navigationRevision: state.navigationRevision + 1,
    ));
  }

  Future<void> _onConfirmArrival(ConfirmCustomerArrivalEvent event) async {
    if (state.isArriving) return;
    final stop = state.selectedStop;
    if (stop == null || stop.isDelivered) return;

    final targetBoxId = stop.boxId;
    emit(state.copyWith(
      isArriving: true,
      clearArrivalFailure: true,
    ));

    final result = await arriveAtDriverCustomerUseCase(
      boxId: targetBoxId,
      request: DriverArrivalRequestEntity(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isArriving: false,
          arrivalResult: data,
          clearArrivalFailure: true,
          navigationRevision: state.navigationRevision + 1,
        ));
      case ApiErrorResult(:final failure):
        // If timeout, reconcile with server to see if arrival was persisted
        if (failure.code == 'requestTimeout' || failure.code == 'connectionTimeout') {
          await _reconcileArrival(targetBoxId);
          if (isClosed) return;
          if (state.hasArrived) {
            emit(state.copyWith(isArriving: false, clearArrivalFailure: true));
            return;
          }
        }
        emit(state.copyWith(
          isArriving: false,
          arrivalFailure: failure,
        ));
    }
  }

  Future<void> _reconcileArrival(String targetBoxId) async {
    final routeResult = await getDriverMapRouteUseCase(focusedStopId: state.selectedStopId);
    if (isClosed) return;
    if (routeResult is ApiSuccessResult) {
      final updatedRoute = (routeResult as ApiSuccessResult).data;
      emit(state.copyWith(route: updatedRoute));
    }
  }

  Future<void> _onProofSelected(DeliveryProofSelectedEvent event) async {
    final newRevision = state.photoRevision + 1;
    emit(state.copyWith(
      localPhotoPath: event.localPath,
      photoRevision: newRevision,
      clearProofStorageKey: true,
      clearUploadedPhotoRevision: true,
      clearUploadFailure: true,
      isUploading: true,
    ));

    final result = await uploadDriverDeliveryProofUseCase(localPath: event.localPath);
    if (isClosed || state.photoRevision != newRevision) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isUploading: false,
          proofStorageKey: data.storageKey,
          uploadedPhotoRevision: newRevision,
          clearUploadFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isUploading: false,
          uploadFailure: failure,
        ));
    }
  }

  Future<void> _onRetryUpload() async {
    final localPath = state.localPhotoPath;
    if (localPath == null || localPath.isEmpty || state.isUploading) return;

    final currentRevision = state.photoRevision;
    emit(state.copyWith(
      isUploading: true,
      clearUploadFailure: true,
    ));

    final result = await uploadDriverDeliveryProofUseCase(localPath: localPath);
    if (isClosed || state.photoRevision != currentRevision) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isUploading: false,
          proofStorageKey: data.storageKey,
          uploadedPhotoRevision: currentRevision,
          clearUploadFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isUploading: false,
          uploadFailure: failure,
        ));
    }
  }

  void _onOtpChanged(OptionalDeliveryOtpChangedEvent event) {
    final normalized = _normalizeDigits(event.value);
    emit(state.copyWith(otpInput: normalized));
  }

  String _normalizeDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], '$i');
    }
    final digitsOnly = result.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;
  }

  Future<void> _onConfirmDelivery(ConfirmCustomerDeliveryEvent event) async {
    if (state.isDelivering || !state.canDeliver) return;

    final stop = state.selectedStop;
    final storageKey = state.proofStorageKey;
    if (stop == null || storageKey == null || storageKey.isEmpty) return;

    final targetBoxId = stop.boxId;
    final currentRevision = state.photoRevision;

    emit(state.copyWith(
      isDelivering: true,
      clearDeliveryFailure: true,
    ));

    final result = await deliverDriverOrderUseCase(
      boxId: targetBoxId,
      request: DriverDeliverRequestEntity(
        proofPhotoStorageKey: storageKey,
        latitude: event.latitude,
        longitude: event.longitude,
        deliveryOtp: state.otpInput.length == 4 ? state.otpInput : null,
      ),
    );

    if (isClosed || state.photoRevision != currentRevision) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isDelivering: false,
          deliveryResult: data,
          clearDeliveryFailure: true,
          navigationRevision: state.navigationRevision + 1,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isDelivering: false,
          deliveryFailure: failure,
        ));
    }
  }

  Future<void> _onReconcile() async {
    await _onRefresh();
  }

  void _onClearNavigation() {
    // Navigation listener consumed
  }

  void _onPaused() {
    // Foreground polling pause handler
  }

  void _onResumed() {
    unawaited(_onRefresh());
  }
}
