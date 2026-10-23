import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../orders/data/realtime/driver_orders_realtime_client.dart';
import '../../../orders/domain/entities/driver_orders_realtime_event.dart';
import '../../domain/entities/driver_support_issues_query_entity.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/entities/driver_support_ticket_status.dart';
import '../../domain/usecase/get_driver_support_issues_usecase.dart';
import 'driver_support_tickets_event.dart';
import 'driver_support_tickets_state.dart';

@injectable
class DriverSupportTicketsViewModel
    extends Cubit<DriverSupportTicketsState> {
  DriverSupportTicketsViewModel({
    required GetDriverSupportIssuesUseCase getDriverSupportIssuesUseCase,
    DriverOrdersRealtimeClient? ordersRealtimeClient,
  })  : _getIssuesUseCase = getDriverSupportIssuesUseCase,
        _realtimeClient = ordersRealtimeClient,
        super(const DriverSupportTicketsState()) {
    _initRealtime();
  }

  final GetDriverSupportIssuesUseCase _getIssuesUseCase;
  final DriverOrdersRealtimeClient? _realtimeClient;

  StreamSubscription<DriverOrdersRealtimeEvent>? _eventsSub;
  StreamSubscription<bool>? _connectionSub;
  Timer? _searchDebounceTimer;
  Timer? _realtimeDebounceTimer;

  int _queryGeneration = 0;
  bool _isLoadingMoreInProgress = false;

  void _initRealtime() {
    final client = _realtimeClient;
    if (client == null) return;

    _eventsSub = client.events.listen((event) {
      if (isClosed) return;
      if (event is DriverSupportIssueUpdatedEvent) {
        doIntent(OnRealtimeTicketUpdatedEvent(issueId: event.issueId));
      } else if (event is DriverConnectionEstablishedEvent) {
        doIntent(const OnRealtimeReconnectedEvent());
      }
    });

    _connectionSub = client.connectionStatus.listen((connected) {
      if (isClosed) return;
      if (connected) {
        doIntent(const OnRealtimeReconnectedEvent());
      }
    });
  }

  void doIntent(DriverSupportTicketsEvent event) {
    if (isClosed) return;
    switch (event) {
      case LoadDriverSupportTicketsEvent():
        unawaited(_loadInitialTickets());
      case ChangeDriverSupportTicketFilterEvent(:final filter):
        _onFilterChanged(filter);
      case SearchDriverSupportTicketsEvent(:final query):
        _onSearchQueryChanged(query);
      case LoadMoreDriverSupportTicketsEvent():
        unawaited(_loadMoreTickets());
      case RefreshDriverSupportTicketsEvent(:final onCompleted):
        unawaited(_refreshTickets(onCompleted));
      case RetryDriverSupportTicketsEvent():
        _onRetry();
      case OnRealtimeTicketUpdatedEvent():
        _handleRealtimeUpdated();
      case OnRealtimeReconnectedEvent():
        _handleRealtimeUpdated();
      case ClearTicketsFeedbackEvent():
        _clearFeedback();
    }
  }

  void _clearFeedback() {
    emit(state.copyWith(
      clearFailure: true,
      clearPaginationFailure: true,
      clearRefreshFailure: true,
    ));
  }

  Future<void> _loadInitialTickets() async {
    _searchDebounceTimer?.cancel();
    final currentGen = ++_queryGeneration;

    emit(state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearPaginationFailure: true,
      clearRefreshFailure: true,
      currentPage: 1,
    ));

    final query = DriverSupportIssuesQueryEntity(
      filter: state.selectedFilter,
      search: state.searchQuery,
      pageNumber: 1,
      pageSize: 20,
    );

    final result = await _getIssuesUseCase(query);
    if (isClosed || currentGen != _queryGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(
          isLoading: false,
          tickets: data.issues,
          allCount: data.allCount,
          underReviewCount: data.underReviewCount,
          awaitingResponseCount: data.awaitingReplyCount,
          resolvedCount: data.resolvedCount,
          totalCount: data.totalCount,
          currentPage: 1,
          hasMore: data.hasMore,
          clearFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isLoading: false,
          failure: failure,
        ));
    }
  }

  void _onFilterChanged(DriverSupportTicketFilter filter) {
    if (state.selectedFilter == filter && state.hasData) return;
    _searchDebounceTimer?.cancel();

    emit(state.copyWith(
      selectedFilter: filter,
      tickets: const [],
      currentPage: 1,
      hasMore: false,
      clearFailure: true,
      clearPaginationFailure: true,
      clearRefreshFailure: true,
    ));

    unawaited(_loadInitialTickets());
  }

  void _onSearchQueryChanged(String query) {
    final trimmed = query.trim();
    if (trimmed == state.searchQuery) return;

    _searchDebounceTimer?.cancel();
    emit(state.copyWith(
      searchQuery: trimmed,
      clearFailure: true,
      clearPaginationFailure: true,
      clearRefreshFailure: true,
    ));

    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (isClosed) return;
      emit(state.copyWith(
        tickets: const [],
        currentPage: 1,
        hasMore: false,
      ));
      unawaited(_loadInitialTickets());
    });
  }

  Future<void> _refreshTickets([void Function()? onCompleted]) async {
    if (state.isRefreshing || state.isLoading) {
      onCompleted?.call();
      return;
    }

    emit(state.copyWith(
      isRefreshing: true,
      clearRefreshFailure: true,
    ));

    final query = DriverSupportIssuesQueryEntity(
      filter: state.selectedFilter,
      search: state.searchQuery,
      pageNumber: 1,
      pageSize: 20,
    );

    final currentGen = _queryGeneration;
    try {
      final result = await _getIssuesUseCase(query);
      if (isClosed || currentGen != _queryGeneration) return;

      switch (result) {
        case ApiSuccessResult(:final data):
          emit(state.copyWith(
            isRefreshing: false,
            tickets: data.issues,
            allCount: data.allCount,
            underReviewCount: data.underReviewCount,
            awaitingResponseCount: data.awaitingReplyCount,
            resolvedCount: data.resolvedCount,
            totalCount: data.totalCount,
            currentPage: 1,
            hasMore: data.hasMore,
            clearRefreshFailure: true,
          ));
        case ApiErrorResult(:final failure):
          emit(state.copyWith(
            isRefreshing: false,
            refreshFailure: failure,
          ));
      }
    } finally {
      onCompleted?.call();
    }
  }

  Future<void> _loadMoreTickets() async {
    if (_isLoadingMoreInProgress ||
        state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    _isLoadingMoreInProgress = true;
    emit(state.copyWith(
      isLoadingMore: true,
      clearPaginationFailure: true,
    ));

    final nextPage = state.currentPage + 1;
    final query = DriverSupportIssuesQueryEntity(
      filter: state.selectedFilter,
      search: state.searchQuery,
      pageNumber: nextPage,
      pageSize: 20,
    );

    final currentGen = _queryGeneration;
    final result = await _getIssuesUseCase(query);
    _isLoadingMoreInProgress = false;

    if (isClosed || currentGen != _queryGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        // Merge and deduplicate by ticket id
        final existingIds = state.tickets.map((t) => t.id).toSet();
        final newItems = <DriverSupportTicketEntity>[];
        for (final item in data.issues) {
          if (!existingIds.contains(item.id)) {
            newItems.add(item);
            existingIds.add(item.id);
          }
        }

        emit(state.copyWith(
          isLoadingMore: false,
          tickets: [...state.tickets, ...newItems],
          currentPage: nextPage,
          totalCount: data.totalCount,
          allCount: data.allCount,
          underReviewCount: data.underReviewCount,
          awaitingResponseCount: data.awaitingReplyCount,
          resolvedCount: data.resolvedCount,
          hasMore: data.hasMore,
          clearPaginationFailure: true,
        ));
      case ApiErrorResult(:final failure):
        emit(state.copyWith(
          isLoadingMore: false,
          paginationFailure: failure,
        ));
    }
  }

  void _onRetry() {
    if (state.failure != null) {
      unawaited(_loadInitialTickets());
    } else if (state.paginationFailure != null) {
      unawaited(_loadMoreTickets());
    } else if (state.refreshFailure != null) {
      unawaited(_refreshTickets());
    } else {
      unawaited(_loadInitialTickets());
    }
  }

  void _handleRealtimeUpdated() {
    _realtimeDebounceTimer?.cancel();
    _realtimeDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      unawaited(_refreshTickets());
    });
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    _realtimeDebounceTimer?.cancel();
    unawaited(_eventsSub?.cancel());
    unawaited(_connectionSub?.cancel());
    return super.close();
  }
}
