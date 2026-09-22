import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../../domain/entities/dispatcher_issue_detail_entity.dart';

const Object _unchanged = Object();

class DispatcherIssueDetailsState {
  const DispatcherIssueDetailsState({
    this.detail,
    this.isInitialLoading = false,
    this.isResolving = false,
    this.initialFailure,
    this.resolveFailure,
    this.resolutionNotesError,
    this.resolveSuccessId = 0,
    this.requiresRefresh = false,
    this.hasLoadedOnce = false,
  });

  final DispatcherIssueDetailEntity? detail;
  final bool isInitialLoading;
  final bool isResolving;
  final Failure? initialFailure;
  final Failure? resolveFailure;
  final String? resolutionNotesError;
  final int resolveSuccessId;
  final bool requiresRefresh;
  final bool hasLoadedOnce;

  bool get canMutate =>
      detail != null && !isResolving && !(detail!.isResolved);

  bool get isResolved => detail?.isResolved ?? false;

  DispatcherIssueDetailsState copyWith({
    Object? detail = _unchanged,
    bool? isInitialLoading,
    bool? isResolving,
    Object? initialFailure = _unchanged,
    Object? resolveFailure = _unchanged,
    Object? resolutionNotesError = _unchanged,
    int? resolveSuccessId,
    bool? requiresRefresh,
    bool? hasLoadedOnce,
  }) {
    return DispatcherIssueDetailsState(
      detail: identical(detail, _unchanged)
          ? this.detail
          : detail as DispatcherIssueDetailEntity?,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isResolving: isResolving ?? this.isResolving,
      initialFailure: identical(initialFailure, _unchanged)
          ? this.initialFailure
          : initialFailure as Failure?,
      resolveFailure: identical(resolveFailure, _unchanged)
          ? this.resolveFailure
          : resolveFailure as Failure?,
      resolutionNotesError: identical(resolutionNotesError, _unchanged)
          ? this.resolutionNotesError
          : resolutionNotesError as String?,
      resolveSuccessId: resolveSuccessId ?? this.resolveSuccessId,
      requiresRefresh: requiresRefresh ?? this.requiresRefresh,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
