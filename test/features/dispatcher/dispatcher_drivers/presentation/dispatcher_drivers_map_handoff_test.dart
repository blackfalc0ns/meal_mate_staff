import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_map_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
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
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/widgets/dispatcher_drivers_map_button.dart';

class _FakeMapHandoffRepo implements DispatcherDriversRepository {
  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) async {
    return const ApiSuccessResult(
      data: DispatcherDriversRosterEntity(
        counts: DispatcherDriversKpiEntity(
          totalCount: 8,
          availableCount: 8,
          busyCount: 0,
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
        drivers: [
          DispatcherDriverEntity(
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
          ),
        ],
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
        message: 'OK',
        boxId: request.boxId,
        driverId: request.driverId,
      ),
    );
  }
}

void main() {
  late _FakeMapHandoffRepo repo;
  late GetDispatcherDriversRosterUseCase getRosterUseCase;
  late AssignDriverToBoxUseCase assignDriverUseCase;

  setUp(() {
    repo = _FakeMapHandoffRepo();
    getRosterUseCase = GetDispatcherDriversRosterUseCase(repo);
    assignDriverUseCase = AssignDriverToBoxUseCase(repo);
  });

  testWidgets('passes selected areaKey and areaName to map in By Area mode', (
    tester,
  ) async {
    DispatcherMapRouteArgs? capturedArgs;
    final vm = DispatcherDriversViewModel(
      args: const DispatcherDriversRouteArgs.browse(),
      getRosterUseCase: getRosterUseCase,
      assignDriverUseCase: assignDriverUseCase,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: DispatcherDriversScreen(
          viewModel: vm,
          onViewOnMap: (args) => capturedArgs = args,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DispatcherDriversMapButton));
    await tester.tap(find.text('عرض السائقين على الخريطة'));
    await tester.pumpAndSettle();

    expect(capturedArgs, isNotNull);
    expect(capturedArgs!.areaKey, 'salmiya');
    expect(capturedArgs!.areaName, 'السالمية');
  });

  testWidgets('passes null area arguments to map in All Drivers mode', (
    tester,
  ) async {
    DispatcherMapRouteArgs? capturedArgs;
    bool wasCallbackInvoked = false;

    final vm = DispatcherDriversViewModel(
      args: const DispatcherDriversRouteArgs.browse(
        initialView: DispatcherDriverViewMode.allDrivers,
      ),
      getRosterUseCase: getRosterUseCase,
      assignDriverUseCase: assignDriverUseCase,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: DispatcherDriversScreen(
          viewModel: vm,
          onViewOnMap: (args) {
            wasCallbackInvoked = true;
            capturedArgs = args;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DispatcherDriversMapButton));
    await tester.tap(find.text('عرض السائقين على الخريطة'));
    await tester.pumpAndSettle();

    expect(wasCallbackInvoked, isTrue);
    expect(capturedArgs, isNull);
  });
}
