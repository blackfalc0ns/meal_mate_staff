import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_issues_page_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_issues_query_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/repo/driver_support_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/usecase/get_driver_support_issues_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/manager/driver_support_tickets_event.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/manager/driver_support_tickets_view_model.dart';

class MockDriverSupportRepository implements DriverSupportRepository {
  DriverSupportIssuesPageEntity? mockPageResult;
  Failure? mockFailure;
  DriverSupportIssuesQueryEntity? lastQuery;
  int callCount = 0;

  @override
  Future<ApiResult<DriverSupportIssuesPageEntity>> getSupportIssues(
    DriverSupportIssuesQueryEntity query,
  ) async {
    callCount++;
    lastQuery = query;
    if (mockFailure != null) {
      return ApiErrorResult(failure: mockFailure!);
    }
    return ApiSuccessResult(data: mockPageResult ?? const DriverSupportIssuesPageEntity());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockDriverSupportRepository repository;
  late GetDriverSupportIssuesUseCase useCase;
  late DriverSupportTicketsViewModel viewModel;

  setUp(() {
    repository = MockDriverSupportRepository();
    useCase = GetDriverSupportIssuesUseCase(repository);
    viewModel = DriverSupportTicketsViewModel(
      getDriverSupportIssuesUseCase: useCase,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DriverSupportTicketsViewModel', () {
    test('LoadDriverSupportTicketsEvent loads tickets and updates counts', () async {
      const mockTicket = DriverSupportTicketEntity(
        id: 't-1',
        boxNumber: '#BX-100',
        title: 'عطل سيارة',
        location: '',
        updatedAt: '2026-10-21',
        status: DriverSupportTicketStatus.awaitingResponse,
      );

      repository.mockPageResult = const DriverSupportIssuesPageEntity(
        allCount: 10,
        underReviewCount: 3,
        awaitingReplyCount: 2,
        resolvedCount: 5,
        totalCount: 10,
        pageNumber: 1,
        pageSize: 20,
        issues: [mockTicket],
      );

      viewModel.doIntent(const LoadDriverSupportTicketsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.tickets.length, equals(1));
      expect(viewModel.state.allCount, equals(10));
      expect(viewModel.state.underReviewCount, equals(3));
      expect(viewModel.state.awaitingResponseCount, equals(2));
      expect(viewModel.state.resolvedCount, equals(5));
      expect(viewModel.state.failure, isNull);
    });

    test('LoadDriverSupportTicketsEvent emits failure on error', () async {
      repository.mockFailure = Failure(
        errorMessage: 'Network error',
        code: 'NETWORK_ERROR',
      );

      viewModel.doIntent(const LoadDriverSupportTicketsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.tickets, isEmpty);
      expect(viewModel.state.failure, isNotNull);
      expect(viewModel.state.failure!.errorMessage, equals('Network error'));
    });

    test('ChangeDriverSupportTicketFilterEvent clears previous items and loads fresh query', () async {
      repository.mockPageResult = const DriverSupportIssuesPageEntity(
        allCount: 5,
        underReviewCount: 2,
        totalCount: 2,
        issues: [
          DriverSupportTicketEntity(
            id: 't-2',
            boxNumber: '#BX-200',
            title: 'قيد المراجعة',
            location: '',
            updatedAt: '2026-10-21',
            status: DriverSupportTicketStatus.underReview,
          ),
        ],
      );

      viewModel.doIntent(
        const ChangeDriverSupportTicketFilterEvent(
          DriverSupportTicketFilter.underReview,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.selectedFilter, equals(DriverSupportTicketFilter.underReview));
      expect(repository.lastQuery?.backendStatus, equals('UnderReview'));
      expect(viewModel.state.tickets.length, equals(1));
    });

    test('LoadMoreDriverSupportTicketsEvent merges and deduplicates tickets', () async {
      // 1. Initial load
      repository.mockPageResult = const DriverSupportIssuesPageEntity(
        allCount: 2,
        totalCount: 2,
        pageNumber: 1,
        pageSize: 1, // simulates hasMore = true
        issues: [
          DriverSupportTicketEntity(
            id: 't-1',
            boxNumber: '#BX-1',
            title: 'أول',
            location: '',
            updatedAt: '2026-10-21',
            status: DriverSupportTicketStatus.underReview,
          ),
        ],
      );

      viewModel.doIntent(const LoadDriverSupportTicketsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.hasMore, isTrue);

      // 2. Load more with duplicate t-1 and new t-2
      repository.mockPageResult = const DriverSupportIssuesPageEntity(
        allCount: 2,
        totalCount: 2,
        pageNumber: 2,
        pageSize: 1,
        issues: [
          DriverSupportTicketEntity(
            id: 't-1', // duplicate
            boxNumber: '#BX-1',
            title: 'أول',
            location: '',
            updatedAt: '2026-10-21',
            status: DriverSupportTicketStatus.underReview,
          ),
          DriverSupportTicketEntity(
            id: 't-2', // new
            boxNumber: '#BX-2',
            title: 'ثاني',
            location: '',
            updatedAt: '2026-10-21',
            status: DriverSupportTicketStatus.underReview,
          ),
        ],
      );

      viewModel.doIntent(const LoadMoreDriverSupportTicketsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.tickets.length, equals(2));
      expect(viewModel.state.tickets.map((t) => t.id).toList(), equals(['t-1', 't-2']));
      expect(viewModel.state.currentPage, equals(2));
    });

    test('LoadMoreDriverSupportTicketsEvent error preserves current tickets and keeps page', () async {
      repository.mockPageResult = const DriverSupportIssuesPageEntity(
        allCount: 5,
        totalCount: 5,
        pageNumber: 1,
        pageSize: 1,
        issues: [
          DriverSupportTicketEntity(
            id: 't-1',
            boxNumber: '#BX-1',
            title: 'أول',
            location: '',
            updatedAt: '2026-10-21',
            status: DriverSupportTicketStatus.underReview,
          ),
        ],
      );

      viewModel.doIntent(const LoadDriverSupportTicketsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      repository.mockFailure = Failure(
        errorMessage: 'Page fetch failed',
        code: 'PAGINATION_ERROR',
      );

      viewModel.doIntent(const LoadMoreDriverSupportTicketsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.tickets.length, equals(1));
      expect(viewModel.state.currentPage, equals(1));
      expect(viewModel.state.paginationFailure, isNotNull);
    });
  });
}
