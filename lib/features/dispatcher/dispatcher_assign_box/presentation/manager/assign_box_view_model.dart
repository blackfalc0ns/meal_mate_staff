import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/network/api_results.dart';
import '../../../dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import '../../../dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';
import '../../domain/usecase/get_assign_box_details_usecase.dart';
import '../../domain/usecase/get_assign_box_summary_usecase.dart';
import 'assign_box_event.dart';
import 'assign_box_state.dart';

@injectable
class AssignBoxViewModel extends Cubit<AssignBoxState> {
  AssignBoxViewModel(
    this._getDetailsUseCase,
    this._getSummaryUseCase,
    this._assignDriverUseCase, {
    @factoryParam String? boxId,
  }) : super(AssignBoxState(boxId: boxId ?? ''));

  final GetAssignBoxDetailsUseCase _getDetailsUseCase;
  final GetAssignBoxSummaryUseCase _getSummaryUseCase;
  final AssignDriverToBoxUseCase _assignDriverUseCase;

  int _requestGeneration = 0;

  Future<void> doIntent(AssignBoxEvent event) async {
    switch (event) {
      case LoadAssignBoxEvent():
        await _loadDetails(isRefresh: false);
      case RetryAssignBoxDetailsEvent():
        await _loadDetails(isRefresh: false);
      case RefreshAssignBoxDetailsEvent():
        await _loadDetails(isRefresh: true);
      case SelectAssignBoxDriverEvent(:final driverId):
        _selectDriver(driverId);
      case LoadAssignBoxSummaryEvent():
        await _loadSummary();
      case RetryAssignBoxSummaryEvent():
        await _retrySummary();
      case SubmitAssignBoxEvent(:final localizedNotes):
        await _submitAssignment(localizedNotes);
      case ClearAssignBoxNoticeEvent():
        _clearNotice();
    }
  }

  Future<void> _loadDetails({required bool isRefresh}) async {
    final generation = ++_requestGeneration;

    if (isRefresh) {
      emit(state.copyWith(isRefreshLoading: true, clearRefreshFailure: true));
    } else {
      emit(state.copyWith(isInitialLoading: true, clearInitialFailure: true));
    }

    final result = await _getDetailsUseCase(state.boxId);

    if (generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        String? newSelection;
        if (isRefresh && state.selectedDriverId != null) {
          final isStillPresent =
              data.bestSuggestion?.driverId == state.selectedDriverId ||
              data.candidates.any((c) => c.driverId == state.selectedDriverId);
          newSelection = isStillPresent
              ? state.selectedDriverId
              : data.defaultSelectedDriverId;
        } else {
          newSelection = data.defaultSelectedDriverId;
        }

        emit(
          state.copyWith(
            details: data,
            selectedDriverId: newSelection,
            clearSelectedDriverId: newSelection == null,
            isInitialLoading: false,
            isRefreshLoading: false,
            clearInitialFailure: true,
            clearRefreshFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        if (isRefresh) {
          emit(
            state.copyWith(
              isRefreshLoading: false,
              refreshFailure: failure,
              noticeId: state.noticeId + 1,
            ),
          );
        } else {
          emit(
            state.copyWith(isInitialLoading: false, initialFailure: failure),
          );
        }
    }
  }

  void _selectDriver(String driverId) {
    emit(state.copyWith(selectedDriverId: driverId));
  }

  Future<void> _loadSummary() async {
    if (state.summary != null) return;
    if (state.isSummaryLoading) return;

    emit(state.copyWith(isSummaryLoading: true, clearSummaryFailure: true));

    final result = await _getSummaryUseCase(state.boxId);

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            summary: data,
            isSummaryLoading: false,
            clearSummaryFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(summaryFailure: failure, isSummaryLoading: false));
    }
  }

  Future<void> _retrySummary() async {
    emit(state.copyWith(clearSummaryFailure: true));
    await _loadSummary();
  }

  Future<void> _submitAssignment(String localizedNotes) async {
    if (!state.canSubmit || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, clearSubmitFailure: true));

    final request = AssignDriverRequestEntity(
      boxId: state.details!.box.boxId,
      driverId: state.selectedDriverId!,
      notes: localizedNotes,
    );

    final result = await _assignDriverUseCase(request);

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isSubmitting: false,
            assignmentResult: data,
            successId: state.successId + 1,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isSubmitting: false,
            submitFailure: failure,
            noticeId: state.noticeId + 1,
          ),
        );

        final isConflict =
            failure.exception.errorType == ApiErrorType.conflict ||
            failure.code == '409' ||
            failure.code.toLowerCase().contains('conflict');
        if (isConflict) {
          await _loadDetails(isRefresh: true);
        }
    }
  }

  void _clearNotice() {
    emit(state.copyWith(clearRefreshFailure: true, clearSubmitFailure: true));
  }
}
