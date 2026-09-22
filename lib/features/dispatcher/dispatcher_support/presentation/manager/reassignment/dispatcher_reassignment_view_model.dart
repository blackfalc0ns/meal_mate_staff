import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../../domain/entities/reassign_driver_candidates_entity.dart';
import '../../../domain/entities/reassign_driver_request_entity.dart';
import '../../../domain/usecase/get_replacement_driver_candidates_usecase.dart';
import '../../../domain/usecase/reassign_dispatcher_issue_usecase.dart';
import 'dispatcher_reassignment_event.dart';
import 'dispatcher_reassignment_state.dart';

class DispatcherReassignmentViewModel
    extends Cubit<DispatcherReassignmentState> {
  DispatcherReassignmentViewModel({
    required this.issueId,
    required this.getCandidatesUseCase,
    required this.reassignUseCase,
  }) : super(const DispatcherReassignmentState());

  final String issueId;
  final GetReplacementDriverCandidatesUseCase getCandidatesUseCase;
  final ReassignDispatcherIssueUseCase reassignUseCase;

  int _requestGeneration = 0;

  Future<void> doIntent(DispatcherReassignmentEvent event) async {
    switch (event) {
      case LoadReplacementCandidates():
        await _loadInitial();
      case RetryReplacementCandidates():
        await _retry();
      case RefreshReplacementCandidates():
        await _refresh();
      case LoadNextReplacementCandidatesPage():
        await _loadNextPage();
      case SelectReplacementDriver():
        _selectDriver(event.driverId);
      case SubmitReplacementDriver():
        await _submit(event.notes);
      case ClearReassignmentFailure():
        emit(
          state.copyWith(
            submitFailure: null,
            pageFailure: null,
          ),
        );
    }
  }

  Future<void> _loadInitial() async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isInitialLoading: true,
        initialFailure: null,
      ),
    );

    final result = await getCandidatesUseCase(issueId, pageNumber: 1);
    if (generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        final firstDriverId =
            data.candidates.isNotEmpty ? data.candidates.first.id : null;
        emit(
          state.copyWith(
            data: data,
            selectedDriverId: firstDriverId,
            isInitialLoading: false,
            initialFailure: null,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitialLoading: false,
            initialFailure: failure,
            data: null,
            selectedDriverId: null,
          ),
        );
    }
  }

  Future<void> _retry() async {
    if (state.data == null) {
      await _loadInitial();
    } else if (state.pageFailure != null) {
      await _loadNextPage();
    } else if (state.submitFailure != null) {
      await _submit(null);
    }
  }

  Future<void> _refresh() async {
    final generation = ++_requestGeneration;
    emit(state.copyWith(isRefreshing: true));

    final result = await getCandidatesUseCase(issueId, pageNumber: 1);
    if (generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        String? newSelectedId = state.selectedDriverId;
        if (newSelectedId != null &&
            !data.candidates.any((c) => c.id == newSelectedId)) {
          newSelectedId = data.candidates.firstOrNull?.id;
        } else if (newSelectedId == null && data.candidates.isNotEmpty) {
          newSelectedId = data.candidates.first.id;
        }

        emit(
          state.copyWith(
            data: data,
            selectedDriverId: newSelectedId,
            isRefreshing: false,
            initialFailure: null,
          ),
        );
      case ApiErrorResult():
        emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> _loadNextPage() async {
    if (state.isLoading || state.data == null || !state.hasNextPage) return;

    emit(state.copyWith(isNextPageLoading: true, pageFailure: null));
    final nextPageNumber = state.data!.pagination.pageNumber + 1;

    final result = await getCandidatesUseCase(
      issueId,
      pageNumber: nextPageNumber,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        final updatedData = state.data!.copyWithAppendedCandidates(
          newCandidates: data.candidates,
          newPagination: data.pagination,
        );
        emit(
          state.copyWith(
            data: updatedData,
            isNextPageLoading: false,
            pageFailure: null,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isNextPageLoading: false,
            pageFailure: failure,
          ),
        );
    }
  }

  void _selectDriver(String driverId) {
    if (state.isSubmitting || state.terminalIssueConflict) return;
    emit(state.copyWith(selectedDriverId: driverId));
  }

  Future<void> _submit(String? notes) async {
    if (state.isSubmitting ||
        state.selectedDriverId == null ||
        state.terminalIssueConflict) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submitFailure: null,
      ),
    );

    final result = await reassignUseCase(
      issueId,
      ReassignDriverRequestEntity(
        replacementDriverId: state.selectedDriverId!,
        notes: notes,
      ),
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isSubmitting: false,
            successResult: data,
            submitFailure: null,
          ),
        );

      case ApiErrorResult(:final failure):
        final isDriverUnavailable =
            failure.code == 'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE' ||
            failure.exception.backendErrorCode ==
                'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE';

        final isTerminalIssueConflict =
            failure.code == 'ISSUE_ALREADY_RESOLVED_OR_REASSIGNED' ||
            failure.exception.backendErrorCode ==
                'ISSUE_ALREADY_RESOLVED_OR_REASSIGNED';

        if (isDriverUnavailable) {
          emit(
            state.copyWith(
              isSubmitting: false,
              selectedDriverId: null,
              submitFailure: failure,
            ),
          );

          final refreshResult = await getCandidatesUseCase(
            issueId,
            pageNumber: 1,
          );
          if (refreshResult
              is ApiSuccessResult<ReassignDriverCandidatesEntity>) {
            final refreshedData = refreshResult.data;
            emit(
              state.copyWith(
                data: refreshedData,
                selectedDriverId: refreshedData.candidates.firstOrNull?.id,
              ),
            );
          }
        } else if (isTerminalIssueConflict) {
          emit(
            state.copyWith(
              isSubmitting: false,
              terminalIssueConflict: true,
              submitFailure: failure,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isSubmitting: false,
              submitFailure: failure,
            ),
          );
        }
    }
  }

  Future<void> load() => doIntent(const LoadReplacementCandidates());
  Future<void> retry() => doIntent(const RetryReplacementCandidates());
  Future<void> refresh() => doIntent(const RefreshReplacementCandidates());
  Future<void> loadNextPage() =>
      doIntent(const LoadNextReplacementCandidatesPage());
  void selectDriver(String driverId) =>
      doIntent(SelectReplacementDriver(driverId));
  Future<void> submit({String? notes}) =>
      doIntent(SubmitReplacementDriver(notes: notes));
  void clearFailure() => doIntent(const ClearReassignmentFailure());
}
