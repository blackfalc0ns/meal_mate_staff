import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
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
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_kpi_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_map_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_section_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_view_switcher.dart';

class _ScreenTestDriversRepo implements DispatcherDriversRepository {
  static List<DispatcherDriverEntity> _createDrivers(
    int count, {
    required String area,
    required String areaKey,
    required int startId,
  }) {
    return List.generate(count, (index) {
      final num = startId + index;
      final isAvailable = index < 5 || (count == 2);
      final name = index == 0
          ? (area == 'حولي' ? 'يوسف الحربي' : 'أحمد محمد')
          : (area == 'حولي' && index == 1 ? 'عمر القحطاني' : 'سائق $num');
      return DispatcherDriverEntity(
        driverId: 'D-$num',
        driverCode: 'ID:D-$num',
        fullName: name,
        rating: 4.8,
        status: isAvailable
            ? DispatcherDriverStatus.available
            : DispatcherDriverStatus.busy,
        statusText: isAvailable ? 'متاح' : 'مشغول',
        statusDotColor: isAvailable ? '#10B981' : '#F59E0B',
        isAvailableForSelection: isAvailable,
        activeOrdersCount: isAvailable ? 0 : 2,
        completedOrdersTodayCount: 10,
        distanceKm: 1.0 + (index * 0.5),
        currentZoneName: area,
        currentZoneKey: areaKey,
      );
    });
  }

  static const areas = [
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
    DispatcherDriverAreaEntity(
      areaKey: 'hateen',
      name: 'حطين',
      driverCount: 1,
      isSelected: false,
    ),
    DispatcherDriverAreaEntity(
      areaKey: 'farwaniya',
      name: 'الفروانية',
      driverCount: 1,
      isSelected: false,
    ),
    DispatcherDriverAreaEntity(
      areaKey: 'capital',
      name: 'العاصمة',
      driverCount: 1,
      isSelected: false,
    ),
  ];

  static const kpi = DispatcherDriversKpiEntity(
    totalCount: 13,
    availableCount: 8,
    busyCount: 5,
  );

  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) async {
    if (query.view == DispatcherDriverViewMode.allDrivers) {
      return ApiSuccessResult(
        data: DispatcherDriversRosterEntity(
          counts: kpi,
          selectedView: DispatcherDriverViewMode.allDrivers,
          selectedAreaKey: null,
          selectedAreaName: '',
          sectionTitle: '',
          areas: areas,
          drivers: _createDrivers(
            13,
            area: 'الكل',
            areaKey: 'all',
            startId: 1025,
          ),
        ),
      );
    }

    final isHawally = query.areaKey == 'hawally' || query.areaName == 'حولي';
    if (isHawally) {
      return ApiSuccessResult(
        data: DispatcherDriversRosterEntity(
          counts: kpi,
          selectedView: DispatcherDriverViewMode.byArea,
          selectedAreaKey: 'hawally',
          selectedAreaName: 'حولي',
          sectionTitle: '',
          areas: areas,
          drivers: _createDrivers(
            2,
            area: 'حولي',
            areaKey: 'hawally',
            startId: 2000,
          ),
        ),
      );
    }

    return ApiSuccessResult(
      data: DispatcherDriversRosterEntity(
        counts: kpi,
        selectedView: DispatcherDriverViewMode.byArea,
        selectedAreaKey: 'salmiya',
        selectedAreaName: 'السالمية',
        sectionTitle: '',
        areas: areas,
        drivers: _createDrivers(
          8,
          area: 'السالمية',
          areaKey: 'salmiya',
          startId: 1025,
        ),
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
  setUp(() async {
    await getIt.reset();
    final repo = _ScreenTestDriversRepo();
    getIt.registerFactoryParam<
      DispatcherDriversViewModel,
      DispatcherDriversRouteArgs?,
      void
    >(
      (args, _) => DispatcherDriversViewModel(
        args: args ?? const DispatcherDriversRouteArgs.browse(),
        getRosterUseCase: GetDispatcherDriversRosterUseCase(repo),
        assignDriverUseCase: AssignDriverToBoxUseCase(repo),
      ),
    );
  });

  Widget buildSubject({
    Locale locale = const Locale('ar'),
    ValueChanged<DispatcherDriverEntity>? onSelectDriver,
    dynamic onViewOnMap,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherDriversScreen(
        onSelectDriver: onSelectDriver,
        onViewOnMap: onViewOnMap,
      ),
    );
  }

  group('DispatcherDriversScreen Widget Tests', () {
    testWidgets('renders all sections and elements in Arabic locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Header
      expect(find.byType(DispatcherDriversHeader), findsOneWidget);
      expect(find.text('قائمة السائقين'), findsOneWidget);
      expect(find.text('اختر السائق المناسب لتوزيع الطلبات'), findsOneWidget);

      // View Switcher
      expect(find.byType(DispatcherDriversViewSwitcher), findsOneWidget);
      expect(find.text('حسب المحافظة'), findsOneWidget);
      expect(find.text('كل السائقين'), findsOneWidget);

      // Area Chips
      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
      expect(find.text('السالمية'), findsWidgets);
      expect(find.text('حولي'), findsOneWidget);
      expect(find.text('حطين'), findsOneWidget);
      expect(find.text('الفروانية', skipOffstage: false), findsOneWidget);
      expect(find.text('العاصمة', skipOffstage: false), findsOneWidget);

      // KPI Card
      expect(find.byType(DispatcherDriversKpiCard), findsOneWidget);
      expect(find.text('إجمالي السائقين'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DispatcherDriversKpiCard),
          matching: find.text('13'),
        ),
        findsOneWidget,
      );
      expect(find.text('السائقين المتاحين'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DispatcherDriversKpiCard),
          matching: find.text('8'),
        ),
        findsOneWidget,
      );
      expect(find.text('مشغول الآن'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DispatcherDriversKpiCard),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );

      // Section Header
      expect(find.byType(DispatcherDriversSectionHeader), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);
      expect(find.text('ترتيب'), findsOneWidget);

      // Driver Cards
      expect(find.byType(DispatcherDriversCard), findsWidgets);
      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('ID:D-1025'), findsOneWidget);
      expect(find.text('متاح'), findsWidgets);
      expect(find.text('اختيار'), findsWidgets);
      expect(find.text('الطلبات الحالية'), findsWidgets);
      expect(find.text('طلبات مكتملة اليوم'), findsWidgets);
      expect(find.text('الـمـسـافـة مـنـك'), findsWidgets);

      // Map Button
      expect(find.byType(DispatcherDriversMapButton), findsOneWidget);
      expect(find.text('عرض السائقين على الخريطة'), findsOneWidget);
    });

    testWidgets('renders all sections and elements in English locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Drivers List'), findsOneWidget);
      expect(
        find.text('Choose the suitable driver for order dispatch'),
        findsOneWidget,
      );
      expect(find.text('By Area'), findsOneWidget);
      expect(find.text('All Drivers'), findsOneWidget);
      expect(find.text('Total Drivers'), findsOneWidget);
      expect(find.text('Available Drivers'), findsOneWidget);
      expect(find.text('Busy Now'), findsOneWidget);
      expect(find.text('Drivers in السالمية (8)'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('View Drivers on Map'), findsOneWidget);
    });

    testWidgets('switches view mode between By Area and All Drivers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);

      // Tap All Drivers
      await tester.tap(find.text('كل السائقين'));
      await tester.pumpAndSettle();

      // Area chips should now be hidden
      expect(find.byType(DispatcherDriversAreaChips), findsNothing);
      expect(find.text('جميع السائقين (13)'), findsOneWidget);

      // Switch back to By Area
      await tester.tap(find.text('حسب المحافظة'));
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherDriversAreaChips), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);
    });

    testWidgets('filters driver list when area chip is selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('السائقين في السالمية (8)'), findsOneWidget);

      // Tap Hawally chip
      await tester.tap(find.text('حولي'));
      await tester.pumpAndSettle();

      expect(find.text('السائقين في حولي (2)'), findsOneWidget);
      expect(find.text('يوسف الحربي'), findsOneWidget);
      expect(find.text('عمر القحطاني'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsNothing);
    });

    testWidgets('invokes onSelectDriver when driver select button is tapped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      DispatcherDriverEntity? selected;
      await tester.pumpWidget(
        buildSubject(onSelectDriver: (d) => selected = d),
      );
      await tester.pumpAndSettle();

      // First driver is Ahmed Mohamed
      final selectButtons = find.text('اختيار');
      expect(selectButtons, findsWidgets);

      await tester.tap(selectButtons.first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'D-1025');
      expect(selected!.name, 'أحمد محمد');
    });

    testWidgets('invokes onSelectDriver when driver card is tapped anywhere', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      DispatcherDriverEntity? selected;
      await tester.pumpWidget(
        buildSubject(onSelectDriver: (d) => selected = d),
      );
      await tester.pumpAndSettle();

      // Tap driver name directly
      await tester.tap(find.text('أحمد محمد'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'D-1025');
      expect(selected!.name, 'أحمد محمد');
    });

    testWidgets('invokes onViewOnMap when map button is tapped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool mapTapped = false;
      await tester.pumpWidget(
        buildSubject(onViewOnMap: () => mapTapped = true),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(DispatcherDriversMapButton));
      await tester.tap(find.text('عرض السائقين على الخريطة'));
      await tester.pumpAndSettle();

      expect(mapTapped, isTrue);
    });

    testWidgets('renders without overflow on narrow viewport (360x720)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DispatcherDriversScreen), findsOneWidget);
    });
  });
}
