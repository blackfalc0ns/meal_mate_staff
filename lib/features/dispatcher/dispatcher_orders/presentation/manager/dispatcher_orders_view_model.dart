import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import '../../domain/usecase/get_dispatcher_order_queue_usecase.dart';
import 'dispatcher_orders_event.dart';
import 'dispatcher_orders_state.dart';

@injectable
class DispatcherOrdersViewModel extends Cubit<DispatcherOrdersState> {
  DispatcherOrdersViewModel({required this.getQueueUseCase})
    : super(const DispatcherOrdersState(isInitialLoading: true));

  final GetDispatcherOrderQueueUseCase getQueueUseCase;

  int _requestGeneration = 0;

  Future<void> doIntent(DispatcherOrdersEvent event) async {
    switch (event) {
      case LoadDispatcherOrdersEvent():
        await _loadInitial();
      case RefreshDispatcherOrdersEvent():
        await _refresh();
      case SelectDispatcherFilterEvent():
        await _changeFilter(event.filter);
      case RetryDispatcherOrdersEvent():
        await _retry();
    }
  }

  Future<void> _loadInitial() async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isInitialLoading: state.queue == null,
        isRefreshLoading: state.queue != null,
        failure: null,
      ),
    );

    await _fetchQueue(generation, state.selectedFilter);
  }

  Future<void> _refresh() async {
    final generation = ++_requestGeneration;
    emit(state.copyWith(isRefreshLoading: true, failure: null));
    await _fetchQueue(generation, state.selectedFilter);
  }

  Future<void> _changeFilter(DispatcherFilterType filter) async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        selectedFilter: filter,
        isFilterLoading: true,
        failure: null,
      ),
    );
    await _fetchQueue(generation, filter);
  }

  Future<void> _retry() async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isInitialLoading: state.queue == null,
        isFilterLoading: state.queue != null,
        failure: null,
      ),
    );
    await _fetchQueue(generation, state.selectedFilter);
  }

  Future<void> _fetchQueue(int generation, DispatcherFilterType filter) async {
    final result = await getQueueUseCase(filter);

    if (isClosed || generation != _requestGeneration) {
      return;
    }

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            queue: data,
            isInitialLoading: false,
            isRefreshLoading: false,
            isFilterLoading: false,
            failure: null,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitialLoading: false,
            isRefreshLoading: false,
            isFilterLoading: false,
            failure: failure,
            hasLoadedOnce: true,
          ),
        );
    }
  }
}
