import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_driver_suggestion_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_filter_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_queue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/entities/dispatcher_order_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/repo/dispatcher_orders_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/usecase/get_dispatcher_order_queue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/manager/dispatcher_orders_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/screens/dispatcher_orders_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_filter_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_filter_chip.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_metrics_grid.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_order_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_orders_list.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/widgets/dispatcher_orders_shimmer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildSubject({
    Locale locale = const Locale('ar'),
    DispatcherOrdersViewModel? viewModel,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherOrdersScreen(viewModel: viewModel),
    );
  }

  testWidgets(
    'renders screen-shaped shimmer when initial loading with no data',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = _OrdersRepository(holdQueue: true);
      final viewModel = _viewModel(repository);

      await tester.pumpWidget(buildSubject(viewModel: viewModel));
      await tester.pump();

      expect(find.byType(DispatcherOrdersShimmer), findsOneWidget);
      expect(find.byType(DispatcherMetricsGrid), findsNothing);

      repository.releaseQueue();
      await tester.pumpAndSettle();
      await viewModel.close();
    },
  );

  testWidgets(
    'renders full-page ApiErrorWidget on initial load failure and retries',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = _OrdersRepository(failQueue: true);
      final viewModel = _viewModel(repository);

      await tester.pumpWidget(buildSubject(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(ApiErrorWidget), findsOneWidget);
      expect(find.byType(DispatcherOrdersList), findsNothing);

      // Tap retry after restoring repository
      repository.failQueue = false;
      final retryBtn = find.byType(AppButton);
      expect(retryBtn, findsOneWidget);
      await tester.tap(retryBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ApiErrorWidget), findsNothing);
      expect(find.byType(DispatcherOrdersList), findsOneWidget);
      await viewModel.close();
    },
  );

  testWidgets(
    'renders EmptyStateWidget when queue is successfully loaded with 0 boxes',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = _OrdersRepository(emptyBoxes: true);
      final viewModel = _viewModel(repository);

      await tester.pumpWidget(buildSubject(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('لا توجد طلبات'), findsOneWidget);
      expect(
        find.text('لا توجد بوكسات في طابور الانتظار لهذه الحالة'),
        findsOneWidget,
      );
      await viewModel.close();
    },
  );

  testWidgets(
    'renders populated dispatcher orders screen with all sections in Arabic',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = _OrdersRepository();
      final viewModel = _viewModel(repository);

      await tester.pumpWidget(buildSubject(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Top Header from backend
      expect(find.text('مطعم MealMate الكويت'), findsOneWidget);
      expect(find.text('Dispatcher'), findsOneWidget);

      // Title Section
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('طابور البوكسات في انتظار الإسناد'), findsOneWidget);

      // Metrics & Filter Section with 120 / 23 / 37 / 58 / 2
      expect(find.byType(DispatcherMetricsGrid), findsOneWidget);
      expect(find.text('120'), findsOneWidget); // All count
      expect(find.text('23'), findsWidgets); // Pending metric + filter count
      expect(find.text('37'), findsWidgets); // Assigned metric + filter count
      expect(find.text('58'), findsWidgets); // InDelivery metric + filter count
      expect(find.text('2'), findsWidgets); // Issues metric + filter count

      // Filter Bar
      expect(find.byType(DispatcherFilterBar), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);

      // Order cards
      expect(find.byType(DispatcherOrderCard), findsWidgets);
      expect(find.text('#BX-1256'), findsOneWidget);
      expect(find.text('جديد'), findsWidgets);
      expect(find.text('منطقة السالمية'), findsOneWidget);
      expect(find.text('إسناد'), findsWidgets);
      expect(find.text('التفاصيل'), findsWidgets);
      await viewModel.close();
    },
  );

  testWidgets('renders populated dispatcher orders screen in English locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repository = _OrdersRepository();
    final viewModel = _viewModel(repository);

    await tester.pumpWidget(
      buildSubject(locale: const Locale('en'), viewModel: viewModel),
    );
    await tester.pumpAndSettle();

    expect(find.text('MealMate Restaurant Kuwait'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Box queue awaiting assignment'), findsOneWidget);
    expect(find.text('Pending Assignment'), findsWidgets);
    expect(find.text('Assign'), findsWidgets);
    expect(find.text('Details'), findsWidgets);
    await viewModel.close();
  });

  testWidgets('tapping filter chip fetches data for that filter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repository = _OrdersRepository();
    final viewModel = _viewModel(repository);

    await tester.pumpWidget(buildSubject(viewModel: viewModel));
    await tester.pumpAndSettle();

    // Tap Pending chip
    final pendingChip = find.widgetWithText(
      DispatcherFilterChip,
      'بانتظار الإسناد',
    );
    expect(pendingChip, findsOneWidget);
    await tester.tap(pendingChip);
    await tester.pumpAndSettle();

    expect(repository.lastFilter, DispatcherFilterType.pendingAssignment);
    await viewModel.close();
  });

  testWidgets(
    'shows shimmer cards while filter loading is in progress',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = _OrdersRepository();
      final viewModel = _viewModel(repository);

      await tester.pumpWidget(buildSubject(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Initially cards are visible
      expect(find.byType(DispatcherOrderCard), findsOneWidget);
      expect(find.byType(DispatcherCardsShimmer), findsNothing);

      // Now hold the next request
      repository.holdQueue = true;
      final pendingChip = find.widgetWithText(
        DispatcherFilterChip,
        'بانتظار الإسناد',
      );
      expect(pendingChip, findsOneWidget);
      await tester.tap(pendingChip);
      await tester.pump();

      // Cards shimmer is displayed during filter loading
      expect(find.byType(DispatcherCardsShimmer), findsOneWidget);
      expect(find.byType(DispatcherOrderCard), findsNothing);

      repository.releaseQueue();
      await tester.pumpAndSettle();

      // Cards shimmer is gone after loading completes
      expect(find.byType(DispatcherCardsShimmer), findsNothing);
      expect(find.byType(DispatcherOrderCard), findsOneWidget);
      await viewModel.close();
    },
  );

  testWidgets(
    'tapping assign button opens AssignBoxScreen via route generator',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = _OrdersRepository();
      getIt.registerFactory<DispatcherOrdersViewModel>(
        () => _viewModel(repository),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.dispatcherOrders,
          onGenerateRoute: RouteGenerator.getRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Tap first assign button
      final assignButtons = find.text('إسناد');
      expect(assignButtons, findsWidgets);

      await tester.tap(assignButtons.first);
      await tester.pumpAndSettle();

      // Should navigate to AssignBoxScreen
      expect(find.text('إسناد البوكس #BX-1256'), findsOneWidget);
      expect(find.text('أفضل اقتراح'), findsOneWidget);
      expect(find.text('اختر سائقاً للإسناد'), findsOneWidget);
      expect(find.text('تأكيد الإسناد'), findsOneWidget);
    },
  );
}

DispatcherOrdersViewModel _viewModel(DispatcherOrdersRepository repository) {
  return DispatcherOrdersViewModel(
    getQueueUseCase: GetDispatcherOrderQueueUseCase(repository),
  );
}

class _OrdersRepository implements DispatcherOrdersRepository {
  _OrdersRepository({
    this.holdQueue = false,
    this.failQueue = false,
    this.emptyBoxes = false,
  });

  bool holdQueue;
  bool failQueue;
  bool emptyBoxes;
  DispatcherFilterType? lastFilter;
  Completer<void>? _completer;

  void releaseQueue() {
    holdQueue = false;
    _completer?.complete();
    _completer = null;
  }

  @override
  Future<ApiResult<DispatcherOrderQueueEntity>> getQueue(
    DispatcherFilterType filter,
  ) async {
    lastFilter = filter;
    if (holdQueue) {
      _completer = Completer<void>();
      await _completer!.future;
    }
    if (failQueue) {
      return ApiErrorResult(
        failure: Failure.fromException(
          const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Queue error',
          ),
        ),
      );
    }
    return ApiSuccessResult(
      data: DispatcherOrderQueueEntity(
        restaurant: const DispatcherOrderQueueRestaurantEntity(
          id: '0a40e4ff-72c7-4754-94e3-50b5f505b730',
          nameAr: 'مطعم MealMate الكويت',
          nameEn: 'MealMate Restaurant Kuwait',
          role: 'Dispatcher',
        ),
        counts: const DispatcherOrderQueueCountsEntity(
          totalCount: 120,
          pendingCount: 23,
          assignedCount: 37,
          inDeliveryCount: 58,
          issuesCount: 2,
        ),
        boxes: emptyBoxes
            ? const []
            : const [
                DispatcherOrderEntity(
                  id: '1',
                  boxCode: '#BX-1256',
                  priority: DispatcherOrderPriority.newOrder,
                  status: DispatcherOrderStatus.pending,
                  area: 'منطقة السالمية',
                  deliveryTimeWindow: '09:30-10:30 ص',
                  mealsCount: 8,
                  distanceKm: 6.2,
                  distanceText: '6.2',
                  priorityBadgeText: 'جديد',
                  suggestion: DispatcherDriverSuggestionEntity(
                    driverId: '1',
                    driverName: 'أحمد',
                    suggestionType: DispatcherDriverSuggestionType.nearest,
                    label: 'الأقرب: أحمد',
                  ),
                ),
              ],
      ),
    );
  }
}
