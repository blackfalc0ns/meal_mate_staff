import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../../domain/entities/reassign_driver_candidates_entity.dart';
import '../../../domain/entities/reassignment_result_entity.dart';

const Object _unchanged = Object();

class DispatcherReassignmentState {
  const DispatcherReassignmentState({
    this.data,
    this.selectedDriverId,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isNextPageLoading = false,
    this.isSubmitting = false,
    this.initialFailure,
    this.pageFailure,
    this.submitFailure,
    this.terminalIssueConflict = false,
    this.successResult,
  });

  final ReassignDriverCandidatesEntity? data;
  final String? selectedDriverId;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isNextPageLoading;
  final bool isSubmitting;
  final Failure? initialFailure;
  final Failure? pageFailure;
  final Failure? submitFailure;
  final bool terminalIssueConflict;
  final ReassignmentResultEntity? successResult;

  bool get isLoading =>
      isInitialLoading || isRefreshing || isNextPageLoading;

  bool get hasCandidates => data?.candidates.isNotEmpty ?? false;

  bool get canSubmit =>
      !isSubmitting &&
      !terminalIssueConflict &&
      selectedDriverId != null &&
      selectedDriverId!.isNotEmpty;

  bool get hasNextPage => data?.pagination.hasNextPage ?? false;

  DispatcherReassignmentState copyWith({
    Object? data = _unchanged,
    Object? selectedDriverId = _unchanged,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isNextPageLoading,
    bool? isSubmitting,
    Object? initialFailure = _unchanged,
    Object? pageFailure = _unchanged,
    Object? submitFailure = _unchanged,
    bool? terminalIssueConflict,
    Object? successResult = _unchanged,
  }) {
    return DispatcherReassignmentState(
      data: identical(data, _unchanged)
          ? this.data
          : data as ReassignDriverCandidatesEntity?,
      selectedDriverId: identical(selectedDriverId, _unchanged)
          ? this.selectedDriverId
          : selectedDriverId as String?,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialFailure: identical(initialFailure, _unchanged)
          ? this.initialFailure
          : initialFailure as Failure?,
      pageFailure: identical(pageFailure, _unchanged)
          ? this.pageFailure
          : pageFailure as Failure?,
      submitFailure: identical(submitFailure, _unchanged)
          ? this.submitFailure
          : submitFailure as Failure?,
      terminalIssueConflict:
          terminalIssueConflict ?? this.terminalIssueConflict,
      successResult: identical(successResult, _unchanged)
          ? this.successResult
          : successResult as ReassignmentResultEntity?,
    );
  }
}
