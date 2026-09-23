import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/network/api_results.dart';
import '../../domain/entities/operations_date_preset.dart';
import '../../domain/entities/operations_query_entity.dart';
import '../../domain/usecase/get_operations_log_usecase.dart';
import 'operations_event.dart';
import 'operations_state.dart';

@injectable
class OperationsViewModel extends Cubit<OperationsState> {
  OperationsViewModel({
    required this.getOperationsLogUseCase,
    this.searchDebounceDuration = const Duration(milliseconds: 400),
  }) : super(const OperationsState());

  final GetOperationsLogUseCase getOperationsLogUseCase;
  final Duration searchDebounceDuration;

  int _requestGeneration = 0;
  Timer? _searchDebounce;
  String _lastFetchedSearch = '';
  OperationsQueryEntity? _lastAttemptedQuery;

  Future<void> doIntent(OperationsEvent event) async {
    switch (event) {
      case LoadOperationsEvent():
        await _loadInitial();
      case RetryOperationsEvent():
        await _retry();
      case RefreshOperationsEvent():
        await _refresh();
      case ChangeOperationsStatusEvent():
        if (state.query.status == event.status) return;
        await _changeQuery(
          state.query.copyWith(status: event.status).resetToFirstPage(),
        );
      case ChangeOperationsSearchEvent():
        _onSearchChanged(event.search);
      case ClearOperationsSearchEvent():
        _searchDebounce?.cancel();
        _lastFetchedSearch = '';
        await _changeQuery(state.query.copyWith(search: '').resetToFirstPage());
      case ChangeOperationsDatePresetEvent():
        if (state.query.datePreset == event.preset &&
            event.preset != OperationsDatePreset.custom) {
          return;
        }
        await _changeQuery(
          state.query
              .copyWith(datePreset: event.preset, clearCustomDates: true)
              .resetToFirstPage(),
        );
      case ChangeOperationsCustomDateRangeEvent():
        await _changeQuery(
          state.query
              .copyWith(
                datePreset: OperationsDatePreset.custom,
                fromDateUtc: event.fromDateUtc,
                toDateUtc: event.toDateUtc,
              )
              .resetToFirstPage(),
        );
      case GoToPreviousOperationsPageEvent():
        if (!state.canGoPrevious) return;
        await _fetchReplacement(
          state.query.copyWith(pageNumber: state.query.pageNumber - 1),
        );
      case GoToNextOperationsPageEvent():
        if (!state.canGoNext) return;
        await _fetchReplacement(
          state.query.copyWith(pageNumber: state.query.pageNumber + 1),
        );
    }
  }

  Future<void> _loadInitial() async {
    _lastFetchedSearch = state.query.search.trim();
    await _fetchReplacement(state.query.resetToFirstPage());
  }

  Future<void> _retry() async {
    if (state.response == null) {
      await _loadInitial();
    } else {
      await _fetchReplacement(_lastAttemptedQuery ?? state.query);
    }
  }

  Future<void> _refresh() async {
    await _fetchReplacement(state.query);
  }

  Future<void> _changeQuery(OperationsQueryEntity newQuery) async {
    _searchDebounce?.cancel();
    _lastFetchedSearch = newQuery.search.trim();
    await _fetchReplacement(newQuery);
  }

  void _onSearchChanged(String input) {
    emit(state.copyWith(query: state.query.copyWith(search: input)));
    _searchDebounce?.cancel();

    final trimmed = input.trim();
    _searchDebounce = Timer(searchDebounceDuration, () {
      if (isClosed || trimmed == _lastFetchedSearch) return;
      _lastFetchedSearch = trimmed;
      unawaited(
        _fetchReplacement(
          state.query.copyWith(search: trimmed).resetToFirstPage(),
        ),
      );
    });
  }

  Future<void> _fetchReplacement(OperationsQueryEntity targetQuery) async {
    _lastAttemptedQuery = targetQuery;
    final generation = ++_requestGeneration;
    final isFirstLoad = state.response == null;
    final previousQuery = state.query;

    emit(
      state.copyWith(
        query: targetQuery,
        isInitialLoading: isFirstLoad,
        isReplacementLoading: !isFirstLoad,
        clearInitialFailure: true,
        clearNonFatalFailure: true,
      ),
    );

    final result = await getOperationsLogUseCase(targetQuery);

    if (isClosed || generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            response: data,
            query: targetQuery,
            isInitialLoading: false,
            isReplacementLoading: false,
            clearInitialFailure: true,
            clearNonFatalFailure: true,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        if (isFirstLoad) {
          emit(
            state.copyWith(
              isInitialLoading: false,
              isReplacementLoading: false,
              initialFailure: failure,
            ),
          );
        } else {
          emit(
            state.copyWith(
              query: previousQuery,
              isInitialLoading: false,
              isReplacementLoading: false,
              nonFatalFailure: failure,
              noticeId: state.noticeId + 1,
            ),
          );
        }
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
