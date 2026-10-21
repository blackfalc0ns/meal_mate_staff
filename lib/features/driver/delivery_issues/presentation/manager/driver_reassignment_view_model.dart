import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_reassignment_details_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../../domain/usecase/get_driver_reassignment_request_details_usecase.dart';
import '../../domain/usecase/get_driver_reassignment_requests_usecase.dart';
import '../../domain/usecase/submit_driver_reassignment_usecase.dart';
import 'driver_reassignment_event.dart';
import 'driver_reassignment_state.dart';

@injectable
class DriverReassignmentViewModel extends Cubit<DriverReassignmentState> {
  DriverReassignmentViewModel({
    required this.submitUseCase,
    required this.getRequestsUseCase,
    required this.getRequestDetailsUseCase,
  }) : super(const DriverReassignmentState());

  final SubmitDriverReassignmentUseCase submitUseCase;
  final GetDriverReassignmentRequestsUseCase getRequestsUseCase;
  final GetDriverReassignmentRequestDetailsUseCase getRequestDetailsUseCase;

  void doIntent(DriverReassignmentEvent event) {
    switch (event) {
      case SubmitDriverReassignmentEvent():
        unawaited(_onSubmit(event));
      case ResetDriverReassignmentStatusEvent():
        _onReset();
      case LoadDriverReassignmentRequestEvent():
        unawaited(_onLoadRequests(event));
      case RefreshDriverReassignmentRequestEvent():
        unawaited(_onRefreshDetails(event));
    }
  }

  Future<void> _onLoadRequests(LoadDriverReassignmentRequestEvent event) async {
    final cleanBoxId = event.boxId.trim();
    if (cleanBoxId.isEmpty) return;

    emit(state.copyWith(
      status: DriverReassignmentStatus.loadingRequest,
      clearFailure: true,
    ));

    final result = await getRequestsUseCase.call(boxId: cleanBoxId);
    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        DriverReassignmentDetailsEntity? active;
        for (final req in data) {
          if (req.isRequested || req.isHandoverActive || (req.isAccepted && !req.isClosed)) {
            active = req;
            break;
          }
        }
        emit(state.copyWith(
          status: DriverReassignmentStatus.idle,
          requests: data,
          activeRequest: active,
          clearFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          status: DriverReassignmentStatus.failed,
          failure: failure,
        ));
    }
  }

  Future<void> _onRefreshDetails(
    RefreshDriverReassignmentRequestEvent event,
  ) async {
    final cleanId = event.requestId.trim();
    if (cleanId.isEmpty) return;

    final result = await getRequestDetailsUseCase.call(cleanId);
    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          activeRequest: data,
          clearFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  Future<void> _onSubmit(SubmitDriverReassignmentEvent event) async {
    if (state.isSubmitting || state.isSuccess || state.isBlocked) {
      return;
    }

    final cleanBoxId = event.boxId.trim();
    if (cleanBoxId.isEmpty) {
      emit(state.copyWith(
        status: DriverReassignmentStatus.failed,
        failure: Failure(
          errorMessage: 'Target box is missing or invalid.',
          code: 'invalid_target',
        ),
      ));
      return;
    }

    final cleanNotes = event.request.notes.trim();
    if (cleanNotes.length > 250) {
      emit(state.copyWith(
        status: DriverReassignmentStatus.failed,
        failure: Failure(
          errorMessage: 'Notes exceed 250 characters limit.',
          code: 'driver.reassignment.notes_too_long',
        ),
      ));
      return;
    }

    final lat = event.request.latitude;
    final lng = event.request.longitude;
    if (lat != null || lng != null) {
      if (lat == null || lng == null) {
        emit(state.copyWith(
          status: DriverReassignmentStatus.failed,
          failure: Failure(
            errorMessage: 'Both latitude and longitude must be provided together.',
            code: 'Orders.CoordinatesPairRequired',
          ),
        ));
        return;
      }
      if (!lat.isFinite || !lng.isFinite || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        emit(state.copyWith(
          status: DriverReassignmentStatus.failed,
          failure: Failure(
            errorMessage: 'Coordinates out of valid range.',
            code: 'Orders.CoordinatesOutOfRange',
          ),
        ));
        return;
      }
    }

    // Set busy synchronously before awaiting
    emit(state.copyWith(
      status: DriverReassignmentStatus.submitting,
      clearFailure: true,
      clearResult: true,
    ));

    final result = await submitUseCase.call(
      boxId: cleanBoxId,
      request: event.request,
    );

    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          status: DriverReassignmentStatus.succeeded,
          result: data,
          clearFailure: true,
        ));
      case ApiErrorResult(:final failure):
        final code = failure.code;
        final backendCode = failure.exception.backendErrorCode;
        final statusCode = failure.exception.statusCode;

        final isConflict = code == 'driver.reassignment.request_already_active' ||
            backendCode == 'driver.reassignment.request_already_active';

        final isTimeout = code == 'connectionTimeout' ||
            code == 'sendTimeout' ||
            code == 'receiveTimeout' ||
            code == 'requestTimeout';

        if (isConflict || isTimeout) {
          final recoveryResult = await getRequestsUseCase.call(boxId: cleanBoxId);
          if (recoveryResult is ApiSuccessResult<List<DriverReassignmentDetailsEntity>> &&
              recoveryResult.data.isNotEmpty) {
            final active = recoveryResult.data.first;
            emit(state.copyWith(
              status: isConflict
                  ? DriverReassignmentStatus.blocked
                  : DriverReassignmentStatus.succeeded,
              activeRequest: active,
              result: ReassignmentResultEntity(
                requestId: active.requestId,
                boxId: active.boxId ?? cleanBoxId,
                status: active.status,
                boxCode: active.boxCode,
                message: active.message,
                requestedAtUtc: active.requestedAtUtc,
              ),
              clearFailure: isTimeout,
              failure: isConflict ? failure : null,
            ));
            return;
          }
        }

        final isBlocked = isConflict ||
            code == 'driver.reassignment.stop_state_not_allowed' ||
            backendCode == 'driver.reassignment.stop_state_not_allowed' ||
            code == 'driver.reassignment.stop_forbidden' ||
            backendCode == 'driver.reassignment.stop_forbidden' ||
            code == 'order.not_found' ||
            backendCode == 'order.not_found' ||
            statusCode == 403;

        emit(state.copyWith(
          status: isBlocked
              ? DriverReassignmentStatus.blocked
              : DriverReassignmentStatus.failed,
          failure: failure,
          clearResult: true,
        ));
    }
  }

  void _onReset() {
    if (isClosed) return;
    emit(state.copyWith(
      status: state.isBlocked
          ? DriverReassignmentStatus.blocked
          : DriverReassignmentStatus.idle,
      clearFailure: true,
      clearResult: true,
    ));
  }
}
