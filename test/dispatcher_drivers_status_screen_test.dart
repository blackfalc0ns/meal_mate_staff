import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_sort.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_drivers_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/screens/dispatcher_drivers_status_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_badge.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_kpi_section.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_pagination.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_sort_button.dart';

class _FakeDriversStatusRepo implements DispatcherDriversStatusRepository {
  DispatcherDriversStatusSummaryEntity? summaryResponse;
  ApiResult<DispatcherDriversStatusSummaryEntity>? summaryResult;
  UpdateDriverAvailabilityResultEntity? toggleResponse;
  ApiResult<UpdateDriverAvailabilityResultEntity>? toggleResult;
  DispatcherDriversStatusQueryEntity? lastQuery;
  UpdateDriverAvailabilityRequestEntity? lastToggleRequest;
  Completer<ApiResult<DispatcherDriversStatusSummaryEntity>>?
  delayLoadCompleter;

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      const Stream.empty();

  @override
  Future<void> acquireRealtime(String ownerId) async {}

  @override
  Future<void> releaseRealtime(String ownerId) async {}

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) async {
    lastQuery = query;
    if (delayLoadCompleter != null) {
      return delayLoadCompleter!.future;
    }
    if (summaryResult != null) return summaryResult!;
    return ApiSuccessResult(
      data:
          summaryResponse ??
          const DispatcherDriversStatusSummaryEntity(
            restaurantName: 'مطعم MealMate الكويت',
            role: 'Dispatcher',
            counts: DispatcherDriversStatusKpisEntity(
              total: 24,
              available: 12,
              inDelivery: 8,
              unavailable: 4,
            ),
            items: [
              DispatcherDriverStatusItemEntity(
                driverId: 'driver-1',
                driverCode: 'DR-1001',
                fullName: 'أحمد محمد',
                phoneNumber: '+96550123456',
                isAvailable: true,
                operationalStatus: DispatcherDriverStatusType.available,
                rating: 4.8,
                ratingsCount: 34,
                vehicleType: 'Car',
                vehicleModel: 'Toyota Corolla',
                vehiclePlate: '12-3456',
              ),
              DispatcherDriverStatusItemEntity(
                driverId: 'driver-2',
                driverCode: 'DR-1002',
                fullName: 'محمد سالم',
                phoneNumber: null,
                isAvailable: false,
                operationalStatus: DispatcherDriverStatusType.unavailable,
                rating: null,
                vehicleType: 'Car',
                vehicleModel: 'Nissan Sunny',
                vehiclePlate: '98-7654',
              ),
              DispatcherDriverStatusItemEntity(
                driverId: 'driver-3',
                driverCode: 'DR-1003',
                fullName: 'خالد علي',
                phoneNumber: '+96550999888',
                isAvailable: false,
                operationalStatus: DispatcherDriverStatusType.inDelivery,
                rating: 4.9,
                vehicleType: 'Car',
                vehicleModel: 'Kia Cerato',
                vehiclePlate: '55-4321',
              ),
            ],
            pagination: DispatcherDriversPaginationEntity(
              pageNumber: 1,
              pageSize: 15,
              totalItems: 24,
              totalPages: 2,
              hasPreviousPage: false,
              hasNextPage: true,
            ),
          ),
    );
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(
    UpdateDriverAvailabilityRequestEntity request,
  ) async {
    lastToggleRequest = request;
    if (toggleResult != null) return toggleResult!;
    return ApiSuccessResult(
      data:
          toggleResponse ??
          UpdateDriverAvailabilityResultEntity(
            driverId: request.driverId,
            isAvailable: request.isAvailable,
            operationalStatus: request.isAvailable
                ? DispatcherDriverStatusType.available
                : DispatcherDriverStatusType.unavailable,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
    );
  }

  @override
  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  ) async => throw UnimplementedError();
}

void main() {
  late _FakeDriversStatusRepo repo;
  late DispatcherDriversStatusViewModel viewModel;

  setUp(() {
    repo = _FakeDriversStatusRepo();
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: GetDriversStatusUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  Widget buildWidget({
    Locale locale = const Locale('ar'),
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: navigatorObserver != null
          ? [navigatorObserver]
          : const [],
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.dispatcherDriverDetails) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Details Screen')),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => DispatcherDriversStatusScreen(viewModel: viewModel),
          settings: settings,
        );
      },
      theme: AppTheme.lightTheme,
      home: DispatcherDriversStatusScreen(viewModel: viewModel),
    );
  }

  testWidgets('renders shimmer during initial load', (tester) async {
    repo.delayLoadCompleter = Completer();
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: GetDriversStatusUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byType(DispatcherDriversStatusShimmer), findsOneWidget);

    repo.delayLoadCompleter!.complete(
      const ApiSuccessResult(
        data: DispatcherDriversStatusSummaryEntity(
          counts: DispatcherDriversStatusKpisEntity(
            total: 0,
            available: 0,
            inDelivery: 0,
            unavailable: 0,
          ),
          items: [],
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('renders exactly four KPI values and driver cards', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherDriversStatusKpiSection), findsOneWidget);
    expect(find.text('24'), findsOneWidget); // Total
    expect(find.text('12'), findsOneWidget); // Available
    expect(find.text('8'), findsOneWidget); // In Delivery
    expect(find.text('4'), findsOneWidget); // Unavailable

    expect(find.byType(DispatcherDriversStatusCard), findsNWidgets(3));
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('محمد سالم'), findsOneWidget);
    expect(find.text('خالد علي'), findsOneWidget);
  });

  testWidgets('renders ApiErrorWidget on initial load failure with retry', (
    tester,
  ) async {
    repo.summaryResult = ApiErrorResult(
      failure: Failure(errorMessage: 'Connection failed'),
    );
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: GetDriversStatusUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsOneWidget);

    repo.summaryResult = null; // Next call succeeds
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsNothing);
    expect(find.byType(DispatcherDriversStatusCard), findsNWidgets(3));
  });

  testWidgets('renders EmptyStateWidget when items list is empty', (
    tester,
  ) async {
    repo.summaryResponse = const DispatcherDriversStatusSummaryEntity(
      counts: DispatcherDriversStatusKpisEntity(
        total: 0,
        available: 0,
        inDelivery: 0,
        unavailable: 0,
      ),
      items: [],
      pagination: DispatcherDriversPaginationEntity(
        pageNumber: 1,
        pageSize: 15,
        totalItems: 0,
        totalPages: 0,
      ),
    );
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: GetDriversStatusUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.byType(DispatcherDriversStatusCard), findsNothing);
  });

  testWidgets('null rating renders "جديد" (New) and null phone disables call', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // driver-2 has rating: null
    expect(find.text('جديد'), findsOneWidget);
    // driver-1 has rating: 4.8
    expect(find.text('4.8'), findsOneWidget);
  });

  testWidgets(
    'inDelivery driver retains inDelivery badge when isAvailable is false',
    (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // driver-3 has operationalStatus: inDelivery, isAvailable: false
      final inDeliveryBadges = find.byWidgetPredicate(
        (w) =>
            w is DispatcherDriversStatusBadge &&
            w.status == DispatcherDriverStatusType.inDelivery,
      );
      expect(inDeliveryBadges, findsOneWidget);
    },
  );

  testWidgets('search dispatches server query', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'أحمد');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repo.lastQuery?.search, 'أحمد');
  });

  testWidgets('sort selection dispatches sort query', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherDriversStatusSortButton), findsOneWidget);
    await tester.tap(find.byType(DispatcherDriversStatusSortButton));
    await tester.pumpAndSettle();

    // Tap highest rated sort
    await tester.tap(find.text('الأعلى تقييماً'));
    await tester.pumpAndSettle();

    expect(repo.lastQuery?.sortBy, DispatcherDriversStatusSort.ratingDesc);
  });

  testWidgets('pagination controls dispatch page change', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherDriversStatusPagination), findsOneWidget);
    final nextBtn = find.byKey(
      const Key('dispatcher_drivers_status_next_page_button'),
    );
    expect(nextBtn, findsOneWidget);

    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(repo.lastQuery?.pageNumber, 2);
  });

  testWidgets('card tap navigates to dispatcher driver details', (
    tester,
  ) async {
    final navObserver = _MockNavObserver();
    await tester.pumpWidget(buildWidget(navigatorObserver: navObserver));
    await tester.pumpAndSettle();

    // Tap first driver card
    await tester.tap(find.text('أحمد محمد'));
    await tester.pumpAndSettle();

    expect(
      navObserver.pushedRoutes.any(
        (r) => r.settings.name == AppRoutes.dispatcherDriverDetails,
      ),
      isTrue,
    );
  });
}

class _MockNavObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRoutes.add(route);
  }
}
