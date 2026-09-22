import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../domain/entities/dispatcher_support_date_preset.dart';
import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../../domain/usecase/get_dispatcher_support_issues_usecase.dart';
import 'dispatcher_support_event.dart';
import 'dispatcher_support_state.dart';

class DispatcherSupportViewModel extends Cubit<DispatcherSupportState> {
  DispatcherSupportViewModel({
    required this.getIssuesUseCase,
    this.searchDebounceDuration = const Duration(milliseconds: 400),
    ScrollController? scrollController,
  })  : scrollController = scrollController ?? ScrollController(),
        super(const DispatcherSupportState()) {
    this.scrollController.addListener(_onScroll);
  }

  final GetDispatcherSupportIssuesUseCase getIssuesUseCase;
  final Duration searchDebounceDuration;
  final ScrollController scrollController;

  int _requestGeneration = 0;
  Timer? _searchDebounce;
  String _lastFetchedSearch = '';

  Future<void> doIntent(DispatcherSupportEvent event) async {
    switch (event) {
      case LoadDispatcherSupportEvent():
        await _loadInitial();
      case RetryDispatcherSupportEvent():
        await _retry();
      case ChangeDispatcherSupportStatusEvent():
        if (state.query.status == event.status) return;
        await _changeQuery(
          state.query.copyWith(status: event.status).resetToFirstPage(),
        );
      case ChangeDispatcherSupportAreaEvent():
        if (state.query.area == event.area) return;
        await _changeQuery(
          state.query.copyWith(area: event.area).resetToFirstPage(),
        );
      case ChangeDispatcherSupportDatePresetEvent():
        if (state.query.datePreset == event.datePreset &&
            event.datePreset != DispatcherSupportDatePreset.custom) {
          return;
        }
        await _changeQuery(
          state.query
              .copyWith(
                datePreset: event.datePreset,
                fromDateUtc: null,
                toDateUtc: null,
              )
              .resetToFirstPage(),
        );
      case ChangeDispatcherSupportCustomDateRangeEvent():
        await _changeQuery(
          state.query
              .copyWith(
                datePreset: DispatcherSupportDatePreset.custom,
                fromDateUtc: event.fromDateUtc,
                toDateUtc: event.toDateUtc,
              )
              .resetToFirstPage(),
        );
      case ChangeDispatcherSupportSearchEvent():
        _onSearchChanged(event.search);
      case ClearDispatcherSupportSearchEvent():
        _searchDebounce?.cancel();
        _lastFetchedSearch = '';
        await _changeQuery(state.query.copyWith(search: '').resetToFirstPage());
      case LoadNextDispatcherSupportPageEvent():
        await _loadNextPage();
    }
  }

  Future<void> _loadInitial() async {
    _lastFetchedSearch = state.query.search.trim();
    await _fetchReplacement(state.query.resetToFirstPage());
  }

  Future<void> _retry() async {
    if (state.response == null) {
      await _loadInitial();
    } else if (state.pageFailure != null) {
      await _loadNextPage();
    } else {
      await _fetchReplacement(state.query);
    }
  }

  Future<void> _changeQuery(DispatcherSupportQueryEntity newQuery) async {
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
      _fetchReplacement(
        state.query.copyWith(search: trimmed).resetToFirstPage(),
      );
    });
  }

  Future<void> _fetchReplacement(DispatcherSupportQueryEntity newQuery) async {
    final generation = ++_requestGeneration;
    final isFirstLoad = state.response == null;

    emit(
      state.copyWith(
        query: newQuery,
        isInitialLoading: isFirstLoad,
        isFilterLoading: !isFirstLoad,
        initialFailure: null,
        nonFatalFailure: null,
        pageFailure: null,
      ),
    );

    final result = await getIssuesUseCase(newQuery);

    if (isClosed || generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            response: data,
            isInitialLoading: false,
            isFilterLoading: false,
            initialFailure: null,
            nonFatalFailure: null,
            hasLoadedOnce: true,
          ),
        );
      case ApiErrorResult(:final failure):
        if (isFirstLoad) {
          emit(
            state.copyWith(
              isInitialLoading: false,
              isFilterLoading: false,
              initialFailure: failure,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isInitialLoading: false,
              isFilterLoading: false,
              nonFatalFailure: failure,
              noticeId: state.noticeId + 1,
            ),
          );
        }
    }
  }

  Future<void> _loadNextPage() async {
    if (state.isNextPageLoading ||
        state.isInitialLoading ||
        state.isFilterLoading) {
      return;
    }
    if (!state.hasNextPage) return;

    final currentGeneration = _requestGeneration;
    final nextPageNumber = state.query.pageNumber + 1;
    final nextQuery = state.query.copyWith(pageNumber: nextPageNumber);

    emit(state.copyWith(isNextPageLoading: true, pageFailure: null));

    final result = await getIssuesUseCase(nextQuery);

    if (isClosed || currentGeneration != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        final existingIssues = state.response?.issues ?? [];
        final existingIds = existingIssues
            .where((i) => i.id.isNotEmpty)
            .map((i) => i.id)
            .toSet();

        final newIssues = data.issues.where((i) {
          if (i.id.isEmpty) return true;
          return !existingIds.contains(i.id);
        }).toList();

        final mergedIssues = [...existingIssues, ...newIssues];

        final mergedResponse = data.copyWith(issues: mergedIssues);

        emit(
          state.copyWith(
            response: mergedResponse,
            query: nextQuery,
            isNextPageLoading: false,
            pageFailure: null,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isNextPageLoading: false, pageFailure: failure));
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      _loadNextPage();
    }
  }

  @override
  Future<void> close() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _searchDebounce?.cancel();
    return super.close();
  }
}
