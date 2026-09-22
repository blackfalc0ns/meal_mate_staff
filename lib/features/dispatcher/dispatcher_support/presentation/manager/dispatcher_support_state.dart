import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../../domain/entities/dispatcher_support_response_entity.dart';

const Object _unchanged = Object();

class DispatcherSupportState {
  const DispatcherSupportState({
    this.response,
    this.query = const DispatcherSupportQueryEntity(),
    this.isInitialLoading = false,
    this.isFilterLoading = false,
    this.isNextPageLoading = false,
    this.initialFailure,
    this.nonFatalFailure,
    this.pageFailure,
    this.noticeId = 0,
    this.hasLoadedOnce = false,
  });

  final DispatcherSupportResponseEntity? response;
  final DispatcherSupportQueryEntity query;
  final bool isInitialLoading;
  final bool isFilterLoading;
  final bool isNextPageLoading;
  final Failure? initialFailure;
  final Failure? nonFatalFailure;
  final Failure? pageFailure;
  final int noticeId;
  final bool hasLoadedOnce;

  bool get isLoading =>
      isInitialLoading || isFilterLoading || isNextPageLoading;

  bool get hasIssues => response?.issues.isNotEmpty ?? false;

  bool get hasNextPage => response?.pagination.hasNextPage ?? false;

  DispatcherSupportState copyWith({
    Object? response = _unchanged,
    DispatcherSupportQueryEntity? query,
    bool? isInitialLoading,
    bool? isFilterLoading,
    bool? isNextPageLoading,
    Object? initialFailure = _unchanged,
    Object? nonFatalFailure = _unchanged,
    Object? pageFailure = _unchanged,
    int? noticeId,
    bool? hasLoadedOnce,
  }) {
    return DispatcherSupportState(
      response: identical(response, _unchanged)
          ? this.response
          : response as DispatcherSupportResponseEntity?,
      query: query ?? this.query,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isFilterLoading: isFilterLoading ?? this.isFilterLoading,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      initialFailure: identical(initialFailure, _unchanged)
          ? this.initialFailure
          : initialFailure as Failure?,
      nonFatalFailure: identical(nonFatalFailure, _unchanged)
          ? this.nonFatalFailure
          : nonFatalFailure as Failure?,
      pageFailure: identical(pageFailure, _unchanged)
          ? this.pageFailure
          : pageFailure as Failure?,
      noticeId: noticeId ?? this.noticeId,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
