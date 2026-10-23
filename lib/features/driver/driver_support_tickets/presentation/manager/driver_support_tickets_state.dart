import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/entities/driver_support_ticket_status.dart';

class DriverSupportTicketsState {
  const DriverSupportTicketsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.tickets = const [],
    this.allCount = 0,
    this.underReviewCount = 0,
    this.awaitingResponseCount = 0,
    this.resolvedCount = 0,
    this.totalCount = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.selectedFilter = DriverSupportTicketFilter.all,
    this.searchQuery = '',
    this.failure,
    this.paginationFailure,
    this.refreshFailure,
  });

  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final List<DriverSupportTicketEntity> tickets;
  final int allCount;
  final int underReviewCount;
  final int awaitingResponseCount;
  final int resolvedCount;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final DriverSupportTicketFilter selectedFilter;
  final String searchQuery;
  final Failure? failure;
  final Failure? paginationFailure;
  final Failure? refreshFailure;

  bool get hasData => tickets.isNotEmpty;
  bool get isEmpty => !isLoading && failure == null && tickets.isEmpty;
  Failure? get initialFailure => failure;

  DriverSupportTicketsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    List<DriverSupportTicketEntity>? tickets,
    int? allCount,
    int? underReviewCount,
    int? awaitingResponseCount,
    int? resolvedCount,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    DriverSupportTicketFilter? selectedFilter,
    String? searchQuery,
    Failure? failure,
    bool clearFailure = false,
    Failure? paginationFailure,
    bool clearPaginationFailure = false,
    Failure? refreshFailure,
    bool clearRefreshFailure = false,
  }) {
    return DriverSupportTicketsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      tickets: tickets ?? this.tickets,
      allCount: allCount ?? this.allCount,
      underReviewCount: underReviewCount ?? this.underReviewCount,
      awaitingResponseCount:
          awaitingResponseCount ?? this.awaitingResponseCount,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : (failure ?? this.failure),
      paginationFailure: clearPaginationFailure
          ? null
          : (paginationFailure ?? this.paginationFailure),
      refreshFailure: clearRefreshFailure
          ? null
          : (refreshFailure ?? this.refreshFailure),
    );
  }
}
