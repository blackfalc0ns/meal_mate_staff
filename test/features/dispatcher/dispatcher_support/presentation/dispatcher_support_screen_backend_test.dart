import 'dart:async';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_support_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_issue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_support_issues_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_support_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_date_filter_sheet.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_empty_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_issue_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_pagination_footer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/support/dispatcher_support_shimmer.dart';

class _TestRepository implements DispatcherSupportRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Completer<ApiResult<DispatcherSupportResponseEntity>>? pendingCompleter;
  ApiResult<DispatcherSupportResponseEntity>? nextResult;
  final List<DispatcherSupportQueryEntity> capturedQueries = [];

  @override
  Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
    DispatcherSupportQueryEntity query,
  ) async {
    capturedQueries.add(query);
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    if (nextResult != null) {
      return nextResult!;
    }
    return ApiSuccessResult(data: _emptyResponse());
  }
}

DispatcherSupportResponseEntity _emptyResponse() {
  return const DispatcherSupportResponseEntity(
    counters: DispatcherSupportKpiEntity(
      currentArea: 'السالمية',
      openCount: 0,
      inProgressCount: 0,
      resolvedCount: 0,
    ),
    areaChips: [
      DispatcherSupportAreaChipEntity(
        areaKey: '',
        displayName: 'كل المناطق',
        count: 0,
      ),
    ],
    issues: [],
    pagination: DispatcherSupportPaginationEntity(),
  );
}

DispatcherSupportResponseEntity _sampleResponse({
  List<DispatcherSupportIssueEntity>? issues,
  bool hasNextPage = false,
  int pageNumber = 1,
}) {
  return DispatcherSupportResponseEntity(
    counters: const DispatcherSupportKpiEntity(
      currentArea: 'السالمية',
      openCount: 1,
      inProgressCount: 0,
      resolvedCount: 0,
    ),
    areaChips: const [
      DispatcherSupportAreaChipEntity(
        areaKey: '',
        displayName: 'كل المناطق',
        count: 1,
      ),
      DispatcherSupportAreaChipEntity(
        areaKey: 'السالمية',
        displayName: 'السالمية',
        count: 1,
      ),
    ],
    issues:
        issues ??
        [
          const DispatcherSupportIssueEntity(
            id: 'ISS-100',
            boxCode: 'BX-999',
            driverName: 'سائق تجريبي',
            area: 'السالمية',
            status: DispatcherSupportStatus.open,
          ),
        ],
    pagination: DispatcherSupportPaginationEntity(
      pageNumber: pageNumber,
      pageSize: 20,
      totalCount: issues?.length ?? 1,
      totalPages: hasNextPage ? pageNumber + 1 : pageNumber,
      hasNextPage: hasNextPage,
      hasPreviousPage: pageNumber > 1,
    ),
  );
}

void main() {
  late _TestRepository repository;
  late GetDispatcherSupportIssuesUseCase useCase;

  setUp(() {
    repository = _TestRepository();
    useCase = GetDispatcherSupportIssuesUseCase(repository);
  });

  DispatcherSupportViewModel createViewModel({
    Duration debounceDuration = Duration.zero,
  }) {
    return DispatcherSupportViewModel(
      getIssuesUseCase: useCase,
      searchDebounceDuration: debounceDuration,
    );
  }

  Widget buildSubject({
    required DispatcherSupportViewModel viewModel,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      navigatorObservers: navigatorObserver != null
          ? [navigatorObserver]
          : const [],
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.dispatcherSupportIssueDetails) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              body: Text(
                'Details: ${(settings.arguments as DispatcherSupportIssueDetailsRouteArgs).issueId}',
              ),
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DispatcherSupportScreen(viewModel: viewModel),
        );
      },
    );
  }

  group('DispatcherSupportScreen Backend Integration Tests', () {
    testWidgets('displays DispatcherSupportShimmer during initial loading', (
      tester,
    ) async {
      repository.pendingCompleter =
          Completer<ApiResult<DispatcherSupportResponseEntity>>();
      final vm = createViewModel();

      await tester.pumpWidget(buildSubject(viewModel: vm));
      await tester.pump();

      expect(find.byType(DispatcherSupportShimmer), findsOneWidget);
      expect(find.byType(DispatcherSupportIssueCard), findsNothing);

      repository.pendingCompleter!.complete(
        ApiSuccessResult(data: _sampleResponse()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherSupportShimmer), findsNothing);
      expect(find.byType(DispatcherSupportIssueCard), findsOneWidget);
      vm.close();
    });

    testWidgets(
      'displays ApiErrorWidget on initial load failure and retries on action',
      (tester) async {
        repository.nextResult = ApiErrorResult(
          failure: Failure(
            errorMessage: 'Server error',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server error',
            ),
          ),
        );
        final vm = createViewModel();

        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsOneWidget);
        expect(find.byType(DispatcherSupportIssueCard), findsNothing);

        // Setup next result as success and tap retry
        repository.nextResult = ApiSuccessResult(data: _sampleResponse());
        final retryButton = find.widgetWithText(AppButton, 'Retry');
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsNothing);
        expect(find.byType(DispatcherSupportIssueCard), findsOneWidget);
        vm.close();
      },
    );

    testWidgets(
      'displays DispatcherSupportEmptyState when response has no issues',
      (tester) async {
        repository.nextResult = ApiSuccessResult(data: _emptyResponse());
        final vm = createViewModel();

        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        expect(find.byType(DispatcherSupportEmptyState), findsOneWidget);
        expect(find.byType(DispatcherSupportIssueCard), findsNothing);
        vm.close();
      },
    );

    testWidgets(
      'shows CherryToast snackbar on non-fatal failure while retaining list',
      (tester) async {
        repository.nextResult = ApiSuccessResult(data: _sampleResponse());
        final vm = createViewModel();

        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        expect(find.byType(DispatcherSupportIssueCard), findsOneWidget);

        // Now set next query to fail
        repository.nextResult = ApiErrorResult(
          failure: Failure(
            errorMessage: 'Connection timeout',
            exception: const ApiException(
              errorType: ApiErrorType.connectionTimeout,
              message: 'Connection timeout',
            ),
          ),
        );

        // Trigger status filter change
        await vm.doIntent(
          const ChangeDispatcherSupportStatusEvent(
            DispatcherSupportStatus.inProgress,
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));

        // Notice snackbar (CherryToast) is shown and existing issue is still rendered
        expect(find.byType(CherryToast), findsOneWidget);
        expect(find.byType(DispatcherSupportIssueCard), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        vm.close();
      },
    );

    testWidgets(
      'paginates when scrolled near bottom and renders pagination footer',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final initialIssues = List.generate(
          10,
          (i) => DispatcherSupportIssueEntity(
            id: 'ISS-$i',
            boxCode: 'BX-$i',
            driverName: 'سائق $i',
            area: 'السالمية',
            status: DispatcherSupportStatus.open,
          ),
        );

        repository.nextResult = ApiSuccessResult(
          data: _sampleResponse(issues: initialIssues, hasNextPage: true),
        );
        final vm = createViewModel();

        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        // Setup page 2 response
        final page2Issues = [
          const DispatcherSupportIssueEntity(
            id: 'ISS-PAGE2',
            boxCode: 'BX-9999',
            driverName: 'سائق الصفحة الثانية',
            area: 'السالمية',
            status: DispatcherSupportStatus.open,
          ),
        ];

        repository.nextResult = ApiSuccessResult(
          data: _sampleResponse(
            issues: page2Issues,
            hasNextPage: false,
            pageNumber: 2,
          ),
        );

        // Scroll down to trigger pagination
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
        );
        await tester.pump();

        expect(find.byType(DispatcherSupportPaginationFooter), findsOneWidget);
        await tester.pumpAndSettle();

        expect(find.text('سائق الصفحة الثانية'), findsOneWidget);
        vm.close();
      },
    );

    testWidgets(
      'tapping issue details forwards DispatcherSupportIssueDetailsRouteArgs',
      (tester) async {
        repository.nextResult = ApiSuccessResult(data: _sampleResponse());
        final vm = createViewModel();

        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        final detailsButton = find.text('عرض التفاصيل');
        expect(detailsButton, findsOneWidget);

        await tester.tap(detailsButton);
        await tester.pumpAndSettle();

        expect(find.text('Details: ISS-100'), findsOneWidget);
        vm.close();
      },
    );

    testWidgets(
      'tapping date filter chip opens DispatcherSupportDateFilterSheet',
      (tester) async {
        repository.nextResult = ApiSuccessResult(data: _sampleResponse());
        final vm = createViewModel();

        await tester.pumpWidget(buildSubject(viewModel: vm));
        await tester.pumpAndSettle();

        final dateChip = find.text('آخر 7 أيام', skipOffstage: false);
        expect(dateChip, findsOneWidget);

        await tester.tap(dateChip);
        await tester.pumpAndSettle();

        expect(find.byType(DispatcherSupportDateFilterSheet), findsOneWidget);
        expect(find.text('اليوم'), findsOneWidget);
        expect(find.text('أمس'), findsOneWidget);

        // Select Today
        await tester.tap(find.text('اليوم'));
        await tester.pumpAndSettle();

        expect(find.byType(DispatcherSupportDateFilterSheet), findsNothing);
        expect(vm.state.query.datePreset, DispatcherSupportDatePreset.today);
        vm.close();
      },
    );

    testWidgets('search clear button clears query and dispatches event', (
      tester,
    ) async {
      repository.nextResult = ApiSuccessResult(data: _sampleResponse());
      final vm = createViewModel();

      await tester.pumpWidget(buildSubject(viewModel: vm));
      await tester.pumpAndSettle();

      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);

      await tester.enterText(searchInput, 'BX-123');
      await tester.pump();

      expect(vm.state.query.search, 'BX-123');

      // Clear button
      final clearButton = find.byIcon(Icons.close_rounded);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(vm.state.query.search, '');
      vm.close();
    });
  });
}
