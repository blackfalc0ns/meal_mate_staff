import '../../../../../../core/network/failures.dart';
import '../../domain/entities/operation_item_entity.dart';
import '../../domain/entities/operations_counters_entity.dart';
import '../../domain/entities/operations_page_entity.dart';
import '../../domain/entities/operations_pagination_entity.dart';
import '../../domain/entities/operations_query_entity.dart';

class OperationsState {
  const OperationsState({
    this.response,
    this.query = const OperationsQueryEntity(),
    this.isInitialLoading = false,
    this.isReplacementLoading = false,
    this.initialFailure,
    this.nonFatalFailure,
    this.noticeId = 0,
    this.hasLoadedOnce = false,
  });

  final OperationsPageEntity? response;
  final OperationsQueryEntity query;
  final bool isInitialLoading;
  final bool isReplacementLoading;
  final Failure? initialFailure;
  final Failure? nonFatalFailure;
  final int noticeId;
  final bool hasLoadedOnce;

  List<OperationItemEntity> get operations => response?.operations ?? const [];
  OperationsCountersEntity get counters =>
      response?.counters ?? const OperationsCountersEntity();
  OperationsPaginationEntity get pagination =>
      response?.pagination ?? const OperationsPaginationEntity();
  bool get hasOperations => operations.isNotEmpty;
  bool get canGoPrevious =>
      !isReplacementLoading && !isInitialLoading && pagination.hasPreviousPage;
  bool get canGoNext =>
      !isReplacementLoading && !isInitialLoading && pagination.hasNextPage;

  OperationsState copyWith({
    OperationsPageEntity? response,
    bool clearResponse = false,
    OperationsQueryEntity? query,
    bool? isInitialLoading,
    bool? isReplacementLoading,
    Failure? initialFailure,
    bool clearInitialFailure = false,
    Failure? nonFatalFailure,
    bool clearNonFatalFailure = false,
    int? noticeId,
    bool? hasLoadedOnce,
  }) {
    return OperationsState(
      response: clearResponse ? null : (response ?? this.response),
      query: query ?? this.query,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isReplacementLoading: isReplacementLoading ?? this.isReplacementLoading,
      initialFailure: clearInitialFailure
          ? null
          : (initialFailure ?? this.initialFailure),
      nonFatalFailure: clearNonFatalFailure
          ? null
          : (nonFatalFailure ?? this.nonFatalFailure),
      noticeId: noticeId ?? this.noticeId,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsState &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          query == other.query &&
          isInitialLoading == other.isInitialLoading &&
          isReplacementLoading == other.isReplacementLoading &&
          initialFailure == other.initialFailure &&
          nonFatalFailure == other.nonFatalFailure &&
          noticeId == other.noticeId &&
          hasLoadedOnce == other.hasLoadedOnce;

  @override
  int get hashCode => Object.hash(
    response,
    query,
    isInitialLoading,
    isReplacementLoading,
    initialFailure,
    nonFatalFailure,
    noticeId,
    hasLoadedOnce,
  );
}
