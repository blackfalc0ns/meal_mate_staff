import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_area_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_roster_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/get_dispatcher_drivers_roster_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/screens/dispatcher_drivers_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_area_chips.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_content_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_empty_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_shimmer.dart';

class FakeDriversRepo implements DispatcherDriversRepository {
  Completer<ApiResult<DispatcherDriversRosterEntity>>? rosterCompleter;
  ApiResult<DispatcherDriversRosterEntity>? directRosterResult;

  Completer<ApiResult<DriverAssignmentResultEntity>>? assignCompleter;
  ApiResult<DriverAssignmentResultEntity>? directAssignResult;

  int getRosterCallCount = 0;
  int assignCallCount = 0;
  DispatcherDriversQueryEntity? lastQuery;
  AssignDriverRequestEntity? lastAssignRequest;

  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) async {
    getRosterCallCount++;
    lastQuery = query;
    if (rosterCompleter != null) {
      return rosterCompleter!.future;
    }
    return directRosterResult ??
        const ApiSuccessResult(
          data: DispatcherDriversRosterEntity(
            counts: DispatcherDriversKpiEntity(
              totalCount: 0,
              availableCount: 0,
              busyCount: 0,
            ),
            selectedView: DispatcherDriverViewMode.byArea,
            selectedAreaKey: 'salmiya',
            selectedAreaName: 'السالمية',
            sectionTitle: 'السائقين في السالمية (0)',
            areas: [],
            drivers: [],
          ),
        );
  }

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) async {
    assignCallCount++;
    lastAssignRequest = request;
    if (assignCompleter != null) {
      return assignCompleter!.future;
    }
    return directAssignResult ??
        ApiSuccessResult(
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
  late FakeDriversRepo fakeRepo;
  late GetDispatcherDriversRosterUseCase getRosterUseCase;
  late AssignDriverToBoxUseCase assignDriverUseCase;

  const sampleAvailableDriver = DispatcherDriverEntity(
    driverId: '11111111-1111-1111-1111-111111111111',
    driverCode: 'ID:D-1025',
    fullName: 'أحمد محمد',
    rating: 4.8,
    status: DispatcherDriverStatus.available,
    statusText: 'متاح',
    statusDotColor: '#10B981',
    isAvailableForSelection: true,
    activeOrdersCount: 0,
    completedOrdersTodayCount: 6,
    distanceKm: 2.1,
    currentZoneName: 'السالمية',
    currentZoneKey: 'salmiya',
  );

  const sampleBusyDriver = DispatcherDriverEntity(
    driverId: '22222222-2222-2222-2222-222222222222',
    driverCode: 'ID:D-1028',
    fullName: 'خالد السعيد',
    rating: 4.6,
    status: DispatcherDriverStatus.busy,
    statusText: 'مشغول',
    statusDotColor: '#F59E0B',
    isAvailableForSelection: false,
    activeOrdersCount: 2,
    completedOrdersTodayCount: 4,
    distanceKm: 4.5,
    currentZoneName: 'السالمية',
    currentZoneKey: 'salmiya',
  );

  const sampleRoster = DispatcherDriversRosterEntity(
    counts: DispatcherDriversKpiEntity(
      totalCount: 13,
      availableCount: 8,
      busyCount: 5,
    ),
    selectedView: DispatcherDriverViewMode.byArea,
    selectedAreaKey: 'salmiya',
    selectedAreaName: 'السالمية',
    sectionTitle: 'السائقين في السالمية (8)',
    areas: [
      DispatcherDriverAreaEntity(
        areaKey: 'salmiya',
        name: 'السالمية',
        driverCount: 8,
        isSelected: true,
      ),
      DispatcherDriverAreaEntity(
        areaKey: 'hawally',
        name: 'حولي',
        driverCount: 2,
        isSelected: false,
      ),
    ],
    drivers: [sampleAvailableDriver, sampleBusyDriver],
  );

  setUp(() {
    fakeRepo = FakeDriversRepo();
    getRosterUseCase = GetDispatcherDriversRosterUseCase(fakeRepo);
    assignDriverUseCase = AssignDriverToBoxUseCase(fakeRepo);
  });

  Widget buildSubject({
    DispatcherDriversRouteArgs args = const DispatcherDriversRouteArgs.browse(),
    DispatcherDriversViewModel? viewModel,
    ValueChanged<DispatcherDriverEntity>? onBrowseDriver,
    ValueChanged<DispatcherDriverEntity>? onSelectDriver,
    ValueChanged<DriverAssignmentResultEntity>? onAssignmentCompleted,
    VoidCallback? onBack,
    dynamic onViewOnMap,
  }) {
    final vm =
        viewModel ??
        DispatcherDriversViewModel(
          args: args,
          getRosterUseCase: getRosterUseCase,
          assignDriverUseCase: assignDriverUseCase,
        );

    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherDriversScreen(
        args: args,
        viewModel: vm,
        onBrowseDriver: onBrowseDriver,
        onSelectDriver: onSelectDriver,
        onAssignmentCompleted: onAssignmentCompleted,
        onBack: onBack,
        onViewOnMap: onViewOnMap,
      ),
    );
  }

  testWidgets('shows full shimmer while initial load is in flight', (
    tester,
  ) async {
    fakeRepo.rosterCompleter = Completer();
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(DispatcherDriversShimmer), findsOneWidget);
  });

  testWidgets('shows ApiErrorWidget on initial failure and retries', (
    tester,
  ) async {
    fakeRepo.directRosterResult = ApiErrorResult(
      failure: ServerFailure(
        errorMessage: 'فشل تحميل السائقين',
        exception: const ApiException(
          errorType: ApiErrorType.serverError,
          message: 'فشل تحميل السائقين',
          statusCode: 500,
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsOneWidget);
    expect(fakeRepo.getRosterCallCount, 1);

    // Tap retry
    fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsNothing);
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(fakeRepo.getRosterCallCount, 2);
  });

  testWidgets('renders loaded roster with areas, KPI, and driver cards', (
    tester,
  ) async {
    fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
    expect(find.text('السالمية'), findsWidgets);
    expect(find.text('حولي'), findsOneWidget);
    expect(find.text('السائقين في السالمية (8)'), findsOneWidget);
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('خالد السعيد'), findsOneWidget);
  });

  testWidgets(
    'switching to All Drivers shimmers content and hides area chips',
    (tester) async {
      fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);

      // Now prepare delayed response for All Drivers
      final allCompleter =
          Completer<ApiResult<DispatcherDriversRosterEntity>>();
      fakeRepo.rosterCompleter = allCompleter;

      await tester.tap(find.text('كل السائقين'));
      await tester.pump();

      // Content shimmer is visible while request is pending
      expect(find.byType(DispatcherDriversContentShimmer), findsOneWidget);
      // Area chips are hidden in All mode
      expect(find.byType(DispatcherDriversAreaChips), findsNothing);

      // Complete the request
      allCompleter.complete(
        const ApiSuccessResult(
          data: DispatcherDriversRosterEntity(
            counts: DispatcherDriversKpiEntity(
              totalCount: 13,
              availableCount: 8,
              busyCount: 5,
            ),
            selectedView: DispatcherDriverViewMode.allDrivers,
            selectedAreaKey: null,
            selectedAreaName: '',
            sectionTitle: 'جميع السائقين (13)',
            areas: [],
            drivers: [sampleAvailableDriver, sampleBusyDriver],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriversContentShimmer), findsNothing);
      expect(find.text('جميع السائقين (13)'), findsOneWidget);
      expect(find.byType(DispatcherDriversAreaChips), findsNothing);
    },
  );

  testWidgets('switching area chip shimmers content until response', (
    tester,
  ) async {
    fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final areaCompleter = Completer<ApiResult<DispatcherDriversRosterEntity>>();
    fakeRepo.rosterCompleter = areaCompleter;

    await tester.tap(find.text('حولي'));
    await tester.pump();

    // Replacement shimmer visible
    expect(find.byType(DispatcherDriversContentShimmer), findsOneWidget);

    areaCompleter.complete(
      const ApiSuccessResult(
        data: DispatcherDriversRosterEntity(
          counts: DispatcherDriversKpiEntity(
            totalCount: 13,
            availableCount: 2,
            busyCount: 0,
          ),
          selectedView: DispatcherDriverViewMode.byArea,
          selectedAreaKey: 'hawally',
          selectedAreaName: 'حولي',
          sectionTitle: 'السائقين في حولي (2)',
          areas: [
            DispatcherDriverAreaEntity(
              areaKey: 'salmiya',
              name: 'السالمية',
              driverCount: 8,
              isSelected: false,
            ),
            DispatcherDriverAreaEntity(
              areaKey: 'hawally',
              name: 'حولي',
              driverCount: 2,
              isSelected: true,
            ),
          ],
          drivers: [sampleAvailableDriver],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherDriversContentShimmer), findsNothing);
    expect(find.text('السائقين في حولي (2)'), findsOneWidget);
  });

  testWidgets('shows empty state when roster returns zero drivers', (
    tester,
  ) async {
    fakeRepo.directRosterResult = const ApiSuccessResult(
      data: DispatcherDriversRosterEntity(
        counts: DispatcherDriversKpiEntity(
          totalCount: 0,
          availableCount: 0,
          busyCount: 0,
        ),
        selectedView: DispatcherDriverViewMode.byArea,
        selectedAreaKey: 'salmiya',
        selectedAreaName: 'السالمية',
        sectionTitle: 'السائقين في السالمية (0)',
        areas: [],
        drivers: [],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherDriversEmptyState), findsOneWidget);
  });

  testWidgets(
    'in browse mode, tapping driver invokes onBrowseDriver callback',
    (tester) async {
      fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);
      DispatcherDriverEntity? browsedDriver;

      await tester.pumpWidget(
        buildSubject(
          args: const DispatcherDriversRouteArgs.browse(),
          onBrowseDriver: (driver) => browsedDriver = driver,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('أحمد محمد'));
      await tester.pumpAndSettle();

      expect(browsedDriver, isNotNull);
      expect(browsedDriver!.fullName, 'أحمد محمد');
      // Ensure no assign API call was made
      expect(fakeRepo.assignCallCount, 0);
    },
  );

  testWidgets(
    'in assignment mode, tapping available driver calls assign API and triggers onAssignmentCompleted',
    (tester) async {
      fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);
      DriverAssignmentResultEntity? completedResult;

      await tester.pumpWidget(
        buildSubject(
          args: const DispatcherDriversRouteArgs.assignment(
            boxId: 'a1111111-1111-1111-1111-111111111111',
          ),
          onAssignmentCompleted: (result) => completedResult = result,
        ),
      );
      await tester.pumpAndSettle();

      // Tap on available driver action button "اختيار"
      await tester.tap(find.text('اختيار').first);
      await tester.pumpAndSettle();

      expect(fakeRepo.assignCallCount, 1);
      expect(
        fakeRepo.lastAssignRequest?.driverId,
        sampleAvailableDriver.driverId,
      );
      expect(completedResult, isNotNull);
      expect(completedResult!.success, isTrue);
    },
  );

  testWidgets(
    'in assignment mode, tapping unavailable driver does not assign',
    (tester) async {
      fakeRepo.directRosterResult = const ApiSuccessResult(data: sampleRoster);

      await tester.pumpWidget(
        buildSubject(
          args: const DispatcherDriversRouteArgs.assignment(
            boxId: 'a1111111-1111-1111-1111-111111111111',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // خالد السعيد is unavailable
      await tester.tap(find.text('خالد السعيد'));
      await tester.pumpAndSettle();

      expect(fakeRepo.assignCallCount, 0);
    },
  );
}
