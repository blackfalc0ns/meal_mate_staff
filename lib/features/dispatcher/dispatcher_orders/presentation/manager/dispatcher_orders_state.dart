import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import '../../domain/entities/dispatcher_order_queue_entity.dart';

const _unchanged = Object();

class DispatcherOrdersState {
  const DispatcherOrdersState({
    this.queue,
    this.selectedFilter = DispatcherFilterType.all,
    this.isInitialLoading = false,
    this.isRefreshLoading = false,
    this.isFilterLoading = false,
    this.failure,
    this.hasLoadedOnce = false,
  });

  final DispatcherOrderQueueEntity? queue;
  final DispatcherFilterType selectedFilter;
  final bool isInitialLoading;
  final bool isRefreshLoading;
  final bool isFilterLoading;
  final Failure? failure;
  final bool hasLoadedOnce;

  bool get isLoading => isInitialLoading || isRefreshLoading || isFilterLoading;

  bool get hasQueue => queue != null;

  DispatcherOrdersState copyWith({
    Object? queue = _unchanged,
    DispatcherFilterType? selectedFilter,
    bool? isInitialLoading,
    bool? isRefreshLoading,
    bool? isFilterLoading,
    Object? failure = _unchanged,
    bool? hasLoadedOnce,
  }) {
    return DispatcherOrdersState(
      queue: identical(queue, _unchanged)
          ? this.queue
          : queue as DispatcherOrderQueueEntity?,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshLoading: isRefreshLoading ?? this.isRefreshLoading,
      isFilterLoading: isFilterLoading ?? this.isFilterLoading,
      failure: identical(failure, _unchanged)
          ? this.failure
          : failure as Failure?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
