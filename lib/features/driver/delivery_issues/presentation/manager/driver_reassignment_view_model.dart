import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../../domain/usecase/submit_driver_reassignment_usecase.dart';
import 'driver_reassignment_event.dart';
import 'driver_reassignment_state.dart';

@injectable
class DriverReassignmentViewModel extends Cubit<DriverReassignmentState> {
  DriverReassignmentViewModel({
    required this.submitUseCase,
  }) : super(const DriverReassignmentState());

  final SubmitDriverReassignmentUseCase submitUseCase;

  void doIntent(DriverReassignmentEvent event) {
    switch (event) {
      case SubmitDriverReassignmentEvent():
        unawaited(_onSubmit(event));
      case ResetDriverReassignmentStatusEvent():
        _onReset();
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

        final isBlocked = code == 'driver.reassignment.request_already_active' ||
            backendCode == 'driver.reassignment.request_already_active' ||
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
