import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_drivers_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/screens/dispatcher_drivers_status_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_kpi_section.dart';

class _FakeDriversStatusRepo implements DispatcherDriversStatusRepository {
  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus() async {
    return const ApiSuccessResult(
      data: DispatcherDriversStatusSummaryEntity(
        restaurantName: 'مطعم MealMate الكويت',
        role: 'Dispatcher',
        kpis: DispatcherDriversStatusKpisEntity(
          connectedCount: 12,
          inDeliveryCount: 8,
          offlineCount: 6,
          totalCount: 26,
        ),
        drivers: [
          DispatcherDriverStatusItemEntity(
            id: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
            name: 'أحمد محمد',
            code: '#37262828',
            avatarUrl: 'assets/images/driver/driver_avatar.png',
            rating: 4.8,
            vehicleType: 'سيارة',
            plateNumber: '#KU-3719',
            status: DispatcherDriverStatusType.available,
            isAvailable: true,
          ),
          DispatcherDriverStatusItemEntity(
            id: '4a6f235e-c04d-45db-9c3f-c39775c96da2',
            name: 'محمد سالم',
            code: '#37262828',
            avatarUrl: 'assets/images/driver/driver_avatar.png',
            rating: 4.6,
            vehicleType: 'سيارة',
            plateNumber: '#KU-3719',
            status: DispatcherDriverStatusType.offline,
            isAvailable: false,
          ),
        ],
      ),
    );
  }

  @override
  Future<ApiResult<bool>> toggleDriverAvailability(String driverId, bool isAvailable) async {
    return ApiSuccessResult(data: isAvailable);
  }
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

  Widget buildWidget({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: DispatcherDriversStatusScreen(viewModel: viewModel),
    );
  }

  testWidgets('renders header, KPIs, and driver cards matching Figma', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.byType(DispatcherDriversStatusHeader), findsOneWidget);
    expect(find.text('حالة السائقين'), findsOneWidget);
    expect(find.text('مطعم MealMate الكويت'), findsOneWidget);

    // Verify KPIs
    expect(find.byType(DispatcherDriversStatusKpiSection), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    // Verify Driver Cards
    expect(find.byType(DispatcherDriversStatusCard), findsNWidgets(2));
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('محمد سالم'), findsOneWidget);
  });

  testWidgets('search filters driver cards list', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('محمد سالم'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'أحمد');
    await tester.pumpAndSettle();

    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('محمد سالم'), findsNothing);
  });

  testWidgets('tapping toggle switch updates driver availability', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    // Tap first switch to toggle off
    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    expect(viewModel.state.summary?.drivers.first.isAvailable, isFalse);
  });
}
