import '../../../../../core/network/failures.dart';
import '../../../dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import '../../domain/entities/assign_box_candidate_driver_entity.dart';
import '../../domain/entities/assign_box_details_entity.dart';
import '../../domain/entities/assign_box_summary_entity.dart';

class AssignBoxState {
  const AssignBoxState({
    required this.boxId,
    this.details,
    this.selectedDriverId,
    this.summary,
    this.isInitialLoading = false,
    this.isRefreshLoading = false,
    this.isSummaryLoading = false,
    this.isSubmitting = false,
    this.initialFailure,
    this.refreshFailure,
    this.summaryFailure,
    this.submitFailure,
    this.assignmentResult,
    this.noticeId = 0,
    this.successId = 0,
  });

  final String boxId;
  final AssignBoxDetailsEntity? details;
  final String? selectedDriverId;
  final AssignBoxSummaryEntity? summary;
  final bool isInitialLoading;
  final bool isRefreshLoading;
  final bool isSummaryLoading;
  final bool isSubmitting;
  final Failure? initialFailure;
  final Failure? refreshFailure;
  final Failure? summaryFailure;
  final Failure? submitFailure;
  final DriverAssignmentResultEntity? assignmentResult;
  final int noticeId;
  final int successId;

  bool get canSubmit =>
      !isSubmitting &&
      selectedDriverId != null &&
      selectedDriverId!.isNotEmpty &&
      details != null;

  AssignBoxCandidateDriverEntity? get selectedDriver {
    if (details == null || selectedDriverId == null) return null;
    if (details!.bestSuggestion?.driverId == selectedDriverId) {
      return details!.bestSuggestion;
    }
    for (final candidate in details!.candidates) {
      if (candidate.driverId == selectedDriverId) {
        return candidate;
      }
    }
    return null;
  }

  bool get hasCandidates =>
      details != null &&
      (details!.bestSuggestion != null || details!.candidates.isNotEmpty);

  AssignBoxState copyWith({
    String? boxId,
    AssignBoxDetailsEntity? details,
    bool clearDetails = false,
    String? selectedDriverId,
    bool clearSelectedDriverId = false,
    AssignBoxSummaryEntity? summary,
    bool clearSummary = false,
    bool? isInitialLoading,
    bool? isRefreshLoading,
    bool? isSummaryLoading,
    bool? isSubmitting,
    Failure? initialFailure,
    bool clearInitialFailure = false,
    Failure? refreshFailure,
    bool clearRefreshFailure = false,
    Failure? summaryFailure,
    bool clearSummaryFailure = false,
    Failure? submitFailure,
    bool clearSubmitFailure = false,
    DriverAssignmentResultEntity? assignmentResult,
    bool clearAssignmentResult = false,
    int? noticeId,
    int? successId,
  }) {
    return AssignBoxState(
      boxId: boxId ?? this.boxId,
      details: clearDetails ? null : (details ?? this.details),
      selectedDriverId: clearSelectedDriverId
          ? null
          : (selectedDriverId ?? this.selectedDriverId),
      summary: clearSummary ? null : (summary ?? this.summary),
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshLoading: isRefreshLoading ?? this.isRefreshLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialFailure: clearInitialFailure
          ? null
          : (initialFailure ?? this.initialFailure),
      refreshFailure: clearRefreshFailure
          ? null
          : (refreshFailure ?? this.refreshFailure),
      summaryFailure: clearSummaryFailure
          ? null
          : (summaryFailure ?? this.summaryFailure),
      submitFailure: clearSubmitFailure
          ? null
          : (submitFailure ?? this.submitFailure),
      assignmentResult: clearAssignmentResult
          ? null
          : (assignmentResult ?? this.assignmentResult),
      noticeId: noticeId ?? this.noticeId,
      successId: successId ?? this.successId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxState &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          details == other.details &&
          selectedDriverId == other.selectedDriverId &&
          summary == other.summary &&
          isInitialLoading == other.isInitialLoading &&
          isRefreshLoading == other.isRefreshLoading &&
          isSummaryLoading == other.isSummaryLoading &&
          isSubmitting == other.isSubmitting &&
          initialFailure == other.initialFailure &&
          refreshFailure == other.refreshFailure &&
          summaryFailure == other.summaryFailure &&
          submitFailure == other.submitFailure &&
          assignmentResult == other.assignmentResult &&
          noticeId == other.noticeId &&
          successId == other.successId;

  @override
  int get hashCode =>
      boxId.hashCode ^
      details.hashCode ^
      selectedDriverId.hashCode ^
      summary.hashCode ^
      isInitialLoading.hashCode ^
      isRefreshLoading.hashCode ^
      isSummaryLoading.hashCode ^
      isSubmitting.hashCode ^
      initialFailure.hashCode ^
      refreshFailure.hashCode ^
      summaryFailure.hashCode ^
      submitFailure.hashCode ^
      assignmentResult.hashCode ^
      noticeId.hashCode ^
      successId.hashCode;
}
