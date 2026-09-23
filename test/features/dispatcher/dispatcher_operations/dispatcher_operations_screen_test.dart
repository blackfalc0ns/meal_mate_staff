import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_customer_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_indicator_color.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_page_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/screens/dispatcher_operations_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_pagination_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_search_filter_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_status_tabs.dart';

class _FakeOperationsRepository implements OperationsLogRepository {
  static const _sampleOperations = [
    OperationItemEntity(
      id: 'OP-10256',
      boxId: 'bx-10256',
      boxCode: '#BX-10256',
      status: OperationStatus.completed,
      customer: OperationsCustomerEntity(
        id: 'c1',
        name: 'أحمد العتيبي',
        area: 'حي الياسمين، الرياض',
        addressText: 'حي الياسمين، الرياض',
      ),
      timeText: '10:45 ص',
      driver: OperationsDriverEntity(
        id: 'd1',
        name: 'أحمد السعيد',
        indicatorColor: OperationsIndicatorColor.green,
      ),
    ),
    OperationItemEntity(
      id: 'OP-10242',
      boxId: 'bx-10242',
      boxCode: '#BX-10242',
      status: OperationStatus.completed,
      customer: OperationsCustomerEntity(
        id: 'c2',
        name: 'أحمد العتيبي',
        area: 'حي الياسمين، الرياض',
        addressText: 'حي الياسمين، الرياض',
      ),
      timeText: '08:15 م',
      driver: OperationsDriverEntity(
        id: 'd2',
        name: 'عبدالله الشهري',
        indicatorColor: OperationsIndicatorColor.green,
      ),
    ),
    OperationItemEntity(
      id: 'OP-10241',
      boxId: 'bx-10241',
      boxCode: '#BX-10241',
      status: OperationStatus.cancelled,
      customer: OperationsCustomerEntity(
        id: 'c3',
        name: 'أحمد العتيبي',
        area: 'حي الياسمين، الرياض',
        addressText: 'حي الياسمين، الرياض',
      ),
      timeText: '06:40 م',
      cancelledByText: 'تم الإلغاء من قبل المطعم',
    ),
  ];

  @override
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  ) async {
    final filtered = _sampleOperations.where((op) {
      if (query.status != OperationStatus.all && op.status != query.status) {
        return false;
      }
      final q = query.search.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matchesBox = op.boxCode.toLowerCase().contains(q);
        final matchesCustomer = op.customer.name.toLowerCase().contains(q);
        final matchesDriver =
            op.driver?.name.toLowerCase().contains(q) ?? false;
        return matchesBox || matchesCustomer || matchesDriver;
      }
      return true;
    }).toList();

    return ApiSuccessResult(
      data: OperationsPageEntity(
        counters: const OperationsCountersEntity(
          allCount: 128,
          completedCount: 96,
          cancelledCount: 3,
          failedCount: 7,
          reassignedCount: 17,
        ),
        operations: filtered,
        pagination: OperationsPaginationEntity(
          pageNumber: query.pageNumber,
          pageSize: 10,
          totalItems: 128,
          totalPages: 13,
          hasPreviousPage: query.pageNumber > 1,
          hasNextPage: query.pageNumber < 13,
        ),
      ),
    );
  }
}

Widget _buildTestableWidget({
  required OperationsViewModel viewModel,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6744C2)),
    ),
    home: DispatcherOperationsScreen(viewModel: viewModel),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DispatcherOperationsScreen Tests', () {
    late _FakeOperationsRepository repository;
    late GetOperationsLogUseCase useCase;
    late OperationsViewModel viewModel;

    setUp(() {
      repository = _FakeOperationsRepository();
      useCase = GetOperationsLogUseCase(repository);
      viewModel = OperationsViewModel(
        getOperationsLogUseCase: useCase,
        searchDebounceDuration: const Duration(milliseconds: 100),
      );
    });

    tearDown(() async {
      await viewModel.close();
    });

    testWidgets('renders all major components in RTL', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestableWidget(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherOperationsScreen), findsOneWidget);
      expect(find.byType(OperationsAppBar), findsOneWidget);
      expect(find.byType(OperationsSearchFilterBar), findsOneWidget);
      expect(find.byType(OperationsStatusTabs), findsOneWidget);
      expect(find.byType(OperationsCard), findsWidgets);
      expect(find.byType(OperationsPaginationBar), findsOneWidget);

      // Verify title "سجل العمليات"
      expect(find.text('سجل العمليات'), findsWidgets);
    });

    testWidgets('filters list by status tab selection', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestableWidget(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Tap on "ملغاة" tab
      final cancelledTab = find.text('ملغاة');
      expect(cancelledTab, findsWidgets);
      await tester.tap(cancelledTab.first);
      await tester.pumpAndSettle();

      // Verify that cancelled card reason is visible
      expect(find.text('تم الإلغاء من قبل المطعم'), findsOneWidget);
    });

    testWidgets('filters list by search query', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestableWidget(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'عبدالله الشهري');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Verify exactly 1 operations card matches
      expect(find.byType(OperationsCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(OperationsCard),
          matching: find.text('عبدالله الشهري'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('pagination bar displays page count and responds to clicks', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestableWidget(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Page text check: "1 من 13"
      expect(find.text('1 من 13'), findsOneWidget);

      // Tap "التالي"
      final nextButton = find.text('التالي');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Page text becomes "2 من 13"
      expect(find.text('2 من 13'), findsOneWidget);
    });
  });
}
