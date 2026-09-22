import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../../domain/entities/dispatcher_issue_resolution_entity.dart';
import '../../../domain/entities/reassignment_result_entity.dart';
import '../../../domain/usecase/get_dispatcher_issue_details_usecase.dart';
import '../../../domain/usecase/resolve_dispatcher_issue_usecase.dart';
import 'dispatcher_issue_details_event.dart';
import 'dispatcher_issue_details_state.dart';

@injectable
class DispatcherIssueDetailsViewModel
    extends Cubit<DispatcherIssueDetailsState> {
  DispatcherIssueDetailsViewModel({
    @factoryParam required this.issueId,
    required this.getDetailsUseCase,
    required this.resolveUseCase,
  }) : super(const DispatcherIssueDetailsState());

  final String issueId;
  final GetDispatcherIssueDetailsUseCase getDetailsUseCase;
  final ResolveDispatcherIssueUseCase resolveUseCase;

  int _requestGeneration = 0;

  Future<void> doIntent(DispatcherIssueDetailsEvent event) async {
    switch (event) {
      case LoadIssueDetails():
        await _loadInitial();
      case RetryIssueDetails():
        await _retry();
      case SubmitIssueResolution():
        await _submitResolution(event.notes);
      case ClearIssueResolutionFailure():
        emit(
          state.copyWith(
            resolveFailure: null,
            resolutionNotesError: null,
          ),
        );
      case ApplyReassignmentResult():
        _applyReassignmentResult(event.result);
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

    final result = await getDetailsUseCase(issueId);
    if (generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            detail: data,
            isInitialLoading: false,
            initialFailure: null,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitialLoading: false,
            initialFailure: failure,
            detail: null,
          ),
        );
    }
  }

  Future<void> _retry() async {
    if (state.detail == null) {
      await _loadInitial();
    } else {
      final generation = ++_requestGeneration;
      emit(state.copyWith(isInitialLoading: true, initialFailure: null));
      final result = await getDetailsUseCase(issueId);
      if (generation != _requestGeneration) return;

      switch (result) {
        case ApiSuccessResult(:final data):
          emit(
            state.copyWith(
              detail: data,
              isInitialLoading: false,
              initialFailure: null,
            ),
          );
        case ApiErrorResult(:final failure):
          emit(
            state.copyWith(
              isInitialLoading: false,
              initialFailure: failure,
            ),
          );
      }
    }
  }

  Future<void> _submitResolution(String notes) async {
    final trimmedNotes = notes.trim();
    if (trimmedNotes.length < 3) {
      emit(
        state.copyWith(
          resolutionNotesError: 'ملاحظات الحل يجب أن تكون 3 أحرف على الأقل',
        ),
      );
      return;
    }
    if (trimmedNotes.length > 500) {
      emit(
        state.copyWith(
          resolutionNotesError: 'ملاحظات الحل لا يمكن أن تتجاوز 500 حرف',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isResolving: true,
        resolveFailure: null,
        resolutionNotesError: null,
      ),
    );

    final result = await resolveUseCase(
      issueId,
      trimmedNotes,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        final updatedDetail = state.detail?.copyWith(
          status: data.status,
          statusLabel: data.statusLabel.isNotEmpty ? data.statusLabel : 'محلولة',
          resolution:
              data.resolution ??
              DispatcherIssueResolutionEntity(
                resolutionNotes: trimmedNotes,
                resolvedAtUtc: DateTime.now().toUtc(),
              ),
        );
        emit(
          state.copyWith(
            isResolving: false,
            detail: updatedDetail,
            resolveSuccessId: state.resolveSuccessId + 1,
            requiresRefresh: true,
            resolveFailure: null,
          ),
        );

      case ApiErrorResult(:final failure):
        final isConflict =
            failure.code == 'ISSUE_ALREADY_RESOLVED' ||
            failure.exception.backendErrorCode == 'ISSUE_ALREADY_RESOLVED';

        if (isConflict) {
          final refreshResult = await getDetailsUseCase(issueId);
          switch (refreshResult) {
            case ApiSuccessResult(:final data):
              emit(
                state.copyWith(
                  isResolving: false,
                  detail: data,
                  requiresRefresh: true,
                  resolveFailure: null,
                ),
              );
            case ApiErrorResult():
              emit(
                state.copyWith(
                  isResolving: false,
                  resolveFailure: failure,
                  requiresRefresh: true,
                ),
              );
          }
        } else {
          emit(
            state.copyWith(
              isResolving: false,
              resolveFailure: failure,
            ),
          );
        }
    }
  }

  void _applyReassignmentResult(ReassignmentResultEntity result) {
    final updatedDetail = state.detail?.copyWith(
      status: result.status,
      statusLabel:
          result.statusLabel.isNotEmpty
              ? result.statusLabel
              : state.detail?.statusLabel,
      driver: result.reassignedDriver ?? state.detail?.driver,
      resolution: result.resolution ?? state.detail?.resolution,
    );
    emit(
      state.copyWith(
        detail: updatedDetail,
        requiresRefresh: true,
      ),
    );
  }

  Future<void> load() => doIntent(const LoadIssueDetails());
  Future<void> retry() => doIntent(const RetryIssueDetails());
  Future<void> resolve(String notes) => doIntent(SubmitIssueResolution(notes));
  void clearResolutionFailure() => doIntent(const ClearIssueResolutionFailure());
  void applyReassignmentResult(ReassignmentResultEntity result) =>
      doIntent(ApplyReassignmentResult(result));
}
