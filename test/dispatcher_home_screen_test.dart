import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_alert_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_area_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_operations_status_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_top_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/repo/dispatcher_home_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_home_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_live_drivers_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_alert_banner.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/widgets/dispatcher_home_shimmer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders shimmer while the initial overview is loading', (
    tester,
  ) async {
    final repository = _HomeRepository(holdOverview: true);
    final viewModel = _viewModel(repository);

    await tester.pumpWidget(_app(viewModel));
    await tester.pump();

    expect(find.byType(DispatcherHomeShimmer), findsOneWidget);
    await viewModel.close();
  });

  testWidgets('renders shared API error when overview fails without data', (
    tester,
  ) async {
    final viewModel = _viewModel(_HomeRepository(failOverview: true));

    await tester.pumpWidget(_app(viewModel));
    await tester.pump();

    expect(find.byType(ApiErrorWidget), findsOneWidget);
    await viewModel.close();
  });

  testWidgets('binds API content and renders Google Map', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    final viewModel = _viewModel(_HomeRepository());

    await tester.pumpWidget(_app(viewModel));
    await tester.pump();

    expect(find.text('مطعم الاختبار'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('87.5%'), findsOneWidget);
    expect(find.text('أحمد السعيد'), findsOneWidget);
    expect(find.byType(GoogleMap), findsOneWidget);
    expect(find.byType(DispatcherHomeAlertBanner), findsOneWidget);
    await viewModel.close();
  });

  testWidgets('map refresh reloads locations without reloading overview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _HomeRepository();
    final viewModel = _viewModel(repository);
    await tester.pumpWidget(_app(viewModel));
    await tester.pump();

    await tester.tap(find.byKey(const Key('dispatcher-map-refresh')));
    await tester.pump();

    expect(repository.overviewCalls, 1);
    expect(repository.driverCalls, 2);
    await viewModel.close();
  });

  testWidgets('renders empty state in map when no drivers are available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);

    final viewModel = _viewModel(
      _HomeRepository(driversData: const []),
    );
    await tester.pumpWidget(_app(viewModel));
    await tester.pump();

    expect(find.text('لا يوجد سائقين متاحين'), findsOneWidget);
    await viewModel.close();
  });

  testWidgets('renders empty state for top drivers and areas when lists are empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);

    const emptyOverview = DispatcherHomeOverviewEntity(
      restaurant: DispatcherHomeRestaurantEntity(
        id: '1',
        nameAr: 'مطعم الاختبار',
        nameEn: 'Test',
        role: 'Dispatcher',
      ),
      greeting: DispatcherHomeGreetingEntity(title: 'مرحبا', subtitle: 'اهلا'),
      kpis: DispatcherHomeKpisEntity(
        totalOrdersToday: 0,
        inDeliveryCount: 0,
        pendingAssignmentCount: 0,
        activeIssuesCount: 0,
      ),
      operationsStatus: DispatcherHomeOperationsStatusEntity(
        completionRate: 0,
        deliveredCount: 0,
        deliveredLabel: '',
        inDeliveryCount: 0,
        inDeliveryLabel: '',
        pendingCount: 0,
        pendingLabel: '',
        cancelledCount: 0,
        cancelledLabel: '',
      ),
      topDrivers: [],
      regions: [],
      activeIssues: DispatcherHomeActiveIssuesEntity(
        count: 0,
        summaryAr: '',
        summaryEn: '',
        items: [],
      ),
    );

    final viewModel = _viewModel(
      _HomeRepository(overviewData: emptyOverview),
    );
    await tester.pumpWidget(_app(viewModel));
    await tester.pump();

    expect(find.text('لا توجد بيانات سائقين حالياً'), findsOneWidget);
    expect(find.text('لا توجد بيانات مناطق حالياً'), findsOneWidget);
    await viewModel.close();
  });

  testWidgets('tapping KPI navigates to the corresponding route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);

    String? pushedRoute;
    final viewModel = _viewModel(_HomeRepository());

    await tester.pumpWidget(
      _app(
        viewModel,
        routes: {
          '/dispatcher-orders': (context) {
            pushedRoute = '/dispatcher-orders';
            return const Scaffold(body: Text('Orders Queue Screen'));
          },
          '/dispatcher-support': (context) {
            pushedRoute = '/dispatcher-support';
            return const Scaffold(body: Text('Support Screen'));
          },
        },
      ),
    );
    await tester.pump();

    // Tap total orders KPI
    await tester.tap(find.text('طلبات اليوم'));
    await tester.pumpAndSettle();
    expect(pushedRoute, '/dispatcher-orders');

    await viewModel.close();
  });
}

Widget _app(
  DispatcherHomeViewModel viewModel, {
  Map<String, WidgetBuilder>? routes,
}) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  routes: routes ?? const {},
  home: DispatcherHomeScreen(viewModel: viewModel),
);

DispatcherHomeViewModel _viewModel(DispatcherHomeRepository repository) =>
    DispatcherHomeViewModel(
      getOverviewUseCase: GetDispatcherHomeOverviewUseCase(repository),
      getLiveDriversUseCase: GetDispatcherLiveDriversUseCase(repository),
    );

class _HomeRepository implements DispatcherHomeRepository {
  _HomeRepository({
    this.failOverview = false,
    this.holdOverview = false,
    this.overviewData = _overview,
    this.driversData = const [_driver],
  });

  final bool failOverview;
  final bool holdOverview;
  final DispatcherHomeOverviewEntity overviewData;
  final List<DispatcherHomeMapDriverPinEntity> driversData;
  int overviewCalls = 0;
  int driverCalls = 0;

  @override
  Future<ApiResult<DispatcherHomeOverviewEntity>> getOverview() {
    overviewCalls++;
    if (holdOverview) {
      return Completer<ApiResult<DispatcherHomeOverviewEntity>>().future;
    }
    if (failOverview) {
      return Future.value(
        ApiErrorResult(
          failure: Failure.fromException(
            const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Overview failed',
            ),
          ),
        ),
      );
    }
    return Future.value(ApiSuccessResult(data: overviewData));
  }

  @override
  Future<ApiResult<List<DispatcherHomeMapDriverPinEntity>>> getLiveDrivers() {
    driverCalls++;
    return Future.value(ApiSuccessResult(data: driversData));
  }
}

const _overview = DispatcherHomeOverviewEntity(
  restaurant: DispatcherHomeRestaurantEntity(
    id: 'restaurant-1',
    nameAr: 'مطعم الاختبار',
    nameEn: 'Test Restaurant',
    role: 'Dispatcher',
  ),
  greeting: DispatcherHomeGreetingEntity(
    title: 'مرحبًا',
    subtitle: 'كل شيء تحت السيطرة',
  ),
  kpis: DispatcherHomeKpisEntity(
    totalOrdersToday: 128,
    inDeliveryCount: 58,
    pendingAssignmentCount: 23,
    activeIssuesCount: 2,
  ),
  operationsStatus: DispatcherHomeOperationsStatusEntity(
    completionRate: 87.5,
    deliveredCount: 112,
    deliveredLabel: '',
    inDeliveryCount: 58,
    inDeliveryLabel: '',
    pendingCount: 23,
    pendingLabel: '',
    cancelledCount: 7,
    cancelledLabel: '',
  ),
  topDrivers: [
    DispatcherHomeTopDriverEntity(
      id: 'driver-1',
      name: 'أحمد السعيد',
      badgeText: 'أعلى تقييم',
      rating: 4.9,
      avatarUrl: '',
      completedDeliveriesToday: 14,
    ),
  ],
  regions: [
    DispatcherHomeAreaSummaryEntity(
      id: 'region-1',
      name: 'السالمية',
      ordersCount: 38,
      isIncreasing: true,
      colorType: DispatcherHomeAreaColorType.salmiya,
      percentageChange: 14.5,
    ),
  ],
  activeIssues: DispatcherHomeActiveIssuesEntity(
    count: 2,
    summaryAr: 'تأخير في التوصيل',
    summaryEn: 'Delivery delay',
    items: [],
  ),
);

const _driver = DispatcherHomeMapDriverPinEntity(
  id: 'driver-1',
  fullName: 'سائق الاختبار',
  phone: '+96550000000',
  plateNumber: 'DX-1',
  statusText: 'متاح',
  status: DispatcherHomePinStatus.available,
  avatarUrl: '',
  latitude: 29.3759,
  longitude: 47.9774,
  heading: 0,
  speedKmh: 0,
  updatedAtUtc: null,
);
