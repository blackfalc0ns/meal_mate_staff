import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/assign_box_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/repo/assign_box_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_summary_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/screens/assign_box_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_bottom_actions.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_recommended_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_roster_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/get_dispatcher_drivers_roster_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model.dart';

const _testBoxId = 'a1111111-1111-1111-1111-111111111111';

const _testDetails = AssignBoxDetailsEntity(
  box: AssignBoxOrderEntity(
    boxId: _testBoxId,
    boxCode: '#BX-1256',
    zoneName: 'منطقة السالمية',
    deliveryTimeWindow: '09:30-10:30 ص',
    mealsCount: 8,
    mealsCountText: '8 وجبات',
    distanceKm: 6.2,
    distanceText: '6.2 كم',
    priority: AssignBoxPriority.high,
    priorityText: 'عالية',
    status: AssignBoxStatus.pending,
    statusText: 'جديد',
  ),
  bestSuggestion: AssignBoxCandidateDriverEntity(
    driverId: 'driver-1',
    fullName: 'سالم الحربي',
    distanceText: '1.2 كم',
    activeOrdersCount: 2,
    currentLoadBoxes: 4,
    currentLoadLabel: '4 بوكسات',
    status: AssignBoxDriverStatusType.available,
    driverStatusText: 'متاح',
    statusTag: 'الأقرب',
    estimatedFinishTimeText: '10:20 ص',
    rank: 1,
    isRecommended: true,
  ),
  candidates: [
    AssignBoxCandidateDriverEntity(
      driverId: 'driver-2',
      fullName: 'أحمد إبراهيم',
      distanceText: '2.5 كم',
      activeOrdersCount: 1,
      currentLoadBoxes: 2,
      currentLoadLabel: '2 بوكسات',
      status: AssignBoxDriverStatusType.available,
      driverStatusText: 'متاح',
      statusTag: 'متاح',
      estimatedFinishTimeText: '10:30 ص',
      rank: 2,
    ),
    AssignBoxCandidateDriverEntity(
      driverId: 'driver-3',
      fullName: 'محمد السعيد',
      distanceText: '3.1 كم',
      activeOrdersCount: 0,
      currentLoadBoxes: 0,
      currentLoadLabel: '0 بوكسات',
      status: AssignBoxDriverStatusType.available,
      driverStatusText: 'متاح',
      statusTag: 'متاح',
      estimatedFinishTimeText: '10:45 ص',
      rank: 3,
    ),
    AssignBoxCandidateDriverEntity(
      driverId: 'driver-4',
      fullName: 'يوسف العتيبي',
      distanceText: '4.0 كم',
      activeOrdersCount: 3,
      currentLoadBoxes: 6,
      currentLoadLabel: '6 بوكسات',
      status: AssignBoxDriverStatusType.busy,
      driverStatusText: 'مشغول',
      statusTag: 'مشغول',
      estimatedFinishTimeText: '11:00 ص',
      rank: 4,
    ),
    AssignBoxCandidateDriverEntity(
      driverId: 'driver-5',
      fullName: 'سالم الدوسري',
      distanceText: '4.8 كم',
      activeOrdersCount: 2,
      currentLoadBoxes: 3,
      currentLoadLabel: '3 بوكسات',
      status: AssignBoxDriverStatusType.inDelivery,
      driverStatusText: 'في التوصيل',
      statusTag: 'في التوصيل',
      estimatedFinishTimeText: '11:15 ص',
      rank: 5,
    ),
  ],
);

class _FakeAssignBoxRepository implements AssignBoxRepository {
  @override
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId) async {
    return const ApiSuccessResult(data: _testDetails);
  }

  @override
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId) async {
    return const ApiSuccessResult(
      data: AssignBoxSummaryEntity(
        boxId: _testBoxId,
        boxCode: '#BX-1256',
        zoneName: 'منطقة السالمية',
        address: 'شارع سالم المبارك، مجمع 4، الدور 2',
        deliveryTimeWindow: '09:30-10:30 ص',
        boxCount: 1,
        customerMaskedId: 'CUST-***-12',
        customerNameMasked: 'خالد ***',
        customerPhoneMasked: '+965 9****123',
        barcode: 'MM-BX-1256-KWT',
        deliveryNotes: null,
        allergies: [],
        meals: [],
      ),
    );
  }
}

class _FakeDriversRepository implements DispatcherDriversRepository {
  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) async {
    return const ApiSuccessResult(
      data: DispatcherDriversRosterEntity(
        counts: DispatcherDriversKpiEntity(
          totalCount: 1,
          availableCount: 1,
          busyCount: 0,
        ),
        selectedView: DispatcherDriverViewMode.byArea,
        selectedAreaKey: 'salmiya',
        selectedAreaName: 'السالمية',
        sectionTitle: 'السائقين في السالمية (1)',
        areas: [],
        drivers: [],
      ),
    );
  }

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) async {
    return ApiSuccessResult(
      data: DriverAssignmentResultEntity(
        success: true,
        message: 'تم الإسناد بنجاح',
        boxId: request.boxId,
        driverId: request.driverId,
      ),
    );
  }
}

void main() {
  setUp(() {
    final driversRepo = _FakeDriversRepository();
    if (getIt.isRegistered<DispatcherDriversViewModel>()) {
      getIt.unregister<DispatcherDriversViewModel>();
    }
    getIt.registerFactoryParam<
      DispatcherDriversViewModel,
      DispatcherDriversRouteArgs?,
      void
    >(
      (args, _) => DispatcherDriversViewModel(
        args: args ?? const DispatcherDriversRouteArgs.browse(),
        getRosterUseCase: GetDispatcherDriversRosterUseCase(driversRepo),
        assignDriverUseCase: AssignDriverToBoxUseCase(driversRepo),
      ),
    );

    if (getIt.isRegistered<AssignBoxViewModel>()) {
      getIt.unregister<AssignBoxViewModel>();
    }
    final boxRepo = _FakeAssignBoxRepository();
    getIt.registerFactoryParam<AssignBoxViewModel, String?, void>(
      (boxId, _) => AssignBoxViewModel(
        GetAssignBoxDetailsUseCase(boxRepo),
        GetAssignBoxSummaryUseCase(boxRepo),
        AssignDriverToBoxUseCase(driversRepo),
        boxId: boxId ?? _testBoxId,
      ),
    );
  });

  Widget buildSubject({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: const AssignBoxScreen(
        args: AssignBoxRouteArgs(boxId: _testBoxId),
      ),
    );
  }

  testWidgets('renders AssignBoxScreen with all components in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // App Bar
    expect(find.byType(CustomAppBar), findsOneWidget);
    expect(find.text('إسناد البوكس #BX-1256'), findsOneWidget);

    // Box Summary Card
    expect(find.byType(AssignBoxSummaryCard), findsOneWidget);
    expect(find.text('#BX-1256'), findsWidgets);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('منطقة السالمية'), findsOneWidget);
    expect(find.text('6.2 كم'), findsWidgets);
    expect(find.text('09:30-10:30 ص'), findsOneWidget);
    expect(find.text('عالية'), findsOneWidget);
    expect(find.text('8 وجبات'), findsOneWidget);

    // Best Suggestion Card
    expect(find.byType(AssignBoxRecommendedCard), findsOneWidget);
    expect(find.text('أفضل اقتراح'), findsOneWidget);
    expect(find.text('سالم الحربي'), findsOneWidget);
    expect(find.text('الأقرب'), findsOneWidget);

    // Candidate Drivers List
    expect(find.text('اختر سائقاً للإسناد'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
    expect(find.byType(AssignBoxDriverCard), findsNWidgets(4));
    expect(find.text('أحمد إبراهيم'), findsOneWidget);
    expect(find.text('محمد السعيد'), findsOneWidget);
    expect(find.text('يوسف العتيبي'), findsOneWidget);
    expect(find.text('سالم الدوسري'), findsOneWidget);

    // Bottom Action Buttons
    expect(find.byType(AssignBoxBottomActions), findsOneWidget);
    expect(find.byType(AppButton), findsNWidgets(2));
    expect(find.text('عرض البوكس'), findsOneWidget);
    expect(find.text('تأكيد الإسناد'), findsOneWidget);
  });

  testWidgets('allows selecting a different candidate driver', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap on Ahmad Ibrahim driver card
    await tester.tap(find.text('أحمد إبراهيم'));
    await tester.pumpAndSettle();

    // Verify radio icon state changed
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
  });

  testWidgets('renders AssignBoxScreen in English locale', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Assign Box #BX-1256'), findsOneWidget);
    expect(find.text('Best Suggestion'), findsOneWidget);
    expect(find.text('Select Driver to Assign'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(find.text('View Box'), findsOneWidget);
    expect(find.text('Confirm Assignment'), findsOneWidget);
  });

  testWidgets(
    'renders AssignBoxScreen on narrow 360px device without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('سالم الحربي'), findsOneWidget);
      expect(find.text('أحمد إبراهيم'), findsOneWidget);
      expect(find.text('محمد السعيد'), findsOneWidget);
    },
  );

  testWidgets('tapping view all navigates to dispatcher drivers screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.getRoute,
        home: const AssignBoxScreen(
          args: AssignBoxRouteArgs(boxId: _testBoxId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('عرض الكل'));
    await tester.pumpAndSettle();

    expect(find.text('قائمة السائقين'), findsOneWidget);
  });
}
