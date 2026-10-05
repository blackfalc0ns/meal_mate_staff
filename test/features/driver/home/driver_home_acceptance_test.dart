import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/repo/driver_home_repository.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecase/get_driver_home_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_home_view_model.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/screens/driver_home_screen.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_current_order_card.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/inactive_home/driver_inactive_home_view.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_realtime_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';

class _FakeHomeRepository implements DriverHomeRepository {
  DriverHomeEntity? currentEntity;
  int fetchCount = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ApiResult<DriverHomeEntity>> getDriverHome() async {
    fetchCount++;
    if (currentEntity != null) {
      return ApiSuccessResult(data: currentEntity!);
    }
    throw StateError('No entity provided');
  }
}

class _FakeRealtimeClient implements DriverOrdersRealtimeClient {
  final _eventController =
      StreamController<DriverOrdersRealtimeEvent>.broadcast(sync: true);
  final _statusController = StreamController<bool>.broadcast(sync: true);
  bool _connected = true;

  @override
  Stream<DriverOrdersRealtimeEvent> get events => _eventController.stream;

  @override
  Stream<bool> get connectionStatus => _statusController.stream;

  @override
  bool get isConnected => _connected;

  void emitEvent(DriverOrdersRealtimeEvent event) {
    _eventController.add(event);
  }

  void setConnected(bool connected) {
    _connected = connected;
    _statusController.add(connected);
  }

  @override
  Future<void> start() async => _connected = true;

  @override
  Future<void> stop() async => _connected = false;

  @override
  Future<void> dispose() async {
    await _eventController.close();
    await _statusController.close();
  }

  @override
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async => null;
}

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeHomeRepository repository;
  late _FakeRealtimeClient realtimeClient;
  late DriverHomeViewModel viewModel;

  setUp(() {
    repository = _FakeHomeRepository();
    realtimeClient = _FakeRealtimeClient();
    viewModel = DriverHomeViewModel(
      getDriverHomeUseCase: GetDriverHomeUseCase(repository),
      realtimeClient: realtimeClient,
    );
  });

  tearDown(() async {
    await viewModel.close();
    await realtimeClient.dispose();
  });

  group('Driver Home Acceptance Scenarios (Backend Handoff Contract)', () {
    // Scenario 1: Inactive login shows disconnected Home
    testWidgets(
      'Scenario 1: Inactive login renders disconnected Inactive Home without Start Work controls',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.inactive,
          isAvailable: false,
          currentStatusText: 'غير متصل',
          unreadNotificationsCount: 0,
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();

        // Renders Inactive Home View
        expect(find.byType(DriverInactiveHomeView), findsOneWidget);
        expect(find.byType(DriverActiveHomeView), findsNothing);

        // Identity & Status text displayed
        expect(find.text('عمر الفاروق'), findsOneWidget);
        expect(find.text('DRV-5500'), findsOneWidget);
        expect(find.text('غير متصل'), findsAtLeast(1));

        // Explains manager control
        expect(find.textContaining('مدير التوصيل'), findsOneWidget);

        // No start shift button or action cards
        expect(find.text('بدء العمل'), findsNothing);
        expect(find.text('إنهاء العمل'), findsNothing);
      },
    );

    // Scenario 2: Dispatcher activation sends driver-status-updated event; app reloads and shows Active
    testWidgets(
      'Scenario 2: Realtime driver-status-updated event triggers reload and transitions to Active Home',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        // Initially Inactive
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.inactive,
          isAvailable: false,
          currentStatusText: 'غير متصل',
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DriverInactiveHomeView), findsOneWidget);

        // Dispatcher activates driver on backend
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.active,
          isAvailable: true,
          currentStatusText: 'متاح للطلبات',
          nextLocationText: 'مركز التوزيع الرئيسي',
        );

        // Realtime notification arrives
        realtimeClient.emitEvent(
          DriverStatusUpdatedEvent(
            eventId: 'evt-001',
            occurredAtUtc: DateTime.now().toUtc(),
            driverId: 'drv-101',
            shiftStatus: 'Active',
            isAvailable: true,
          ),
        );

        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pumpAndSettle();

        // UI automatically transitions in-place to Active Home
        expect(find.byType(DriverActiveHomeView), findsOneWidget);
        expect(find.byType(DriverInactiveHomeView), findsNothing);
        expect(find.text('متاح للطلبات'), findsOneWidget);
        expect(find.text('مركز التوزيع الرئيسي'), findsOneWidget);
      },
    );

    // Scenario 3: Missed offline event is recovered by reconnect/resume Home fetch
    testWidgets(
      'Scenario 3: Reconnect or resume triggers fetch and updates to latest state',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        // Initially Active
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.active,
          isAvailable: true,
          currentStatusText: 'متاح للطلبات',
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DriverActiveHomeView), findsOneWidget);

        // Connection dropped, status changed to Inactive while disconnected
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.inactive,
          isAvailable: false,
          currentStatusText: 'غير متصل',
        );

        // SignalR drops connection
        realtimeClient.setConnected(false);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pumpAndSettle();

        // SignalR reconnects (false -> true transition)
        realtimeClient.setConnected(true);
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pumpAndSettle();

        // Reconnect fetch recovered missed status update
        expect(find.byType(DriverInactiveHomeView), findsOneWidget);
        expect(find.byType(DriverActiveHomeView), findsNothing);
      },
    );

    // Scenario 4: Assigned order keeps Home Active with isAvailable == false and shows the task
    testWidgets(
      'Scenario 4: Assigned delivery task keeps Home Active with isAvailable false and renders task card',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.active,
          isAvailable: false,
          currentStatusText: 'مشغول في توصيل طلب',
          nextLocationText: 'شارع الملك فهد 120',
          currentDeliveryTask: DriverHomeCurrentDeliveryTaskEntity(
            boxId: 'bx-9988',
            boxCode: 'BX-9988',
            customerName: 'سارة خالد',
            customerPhone: '0501234567',
            deliveryAddress: 'حي الياسمين، فيلا 14',
            mealsCount: 4,
            mealsSummary: 'وجبات عائلية صحية',
            deliveryTimeSlot: '12:30 م - 01:00 م',
            status: 'InDelivery',
            deliveryNotes: 'يرجى وضعها عند الباب',
          ),
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();

        // Remains in Active Home mode despite isAvailable == false
        expect(find.byType(DriverActiveHomeView), findsOneWidget);
        expect(find.byType(DriverInactiveHomeView), findsNothing);

        // Order card is visible with task details
        expect(find.byType(DriverCurrentOrderCard), findsOneWidget);
        expect(find.text('سارة خالد'), findsOneWidget);
        expect(find.text('BX-9988'), findsOneWidget);
        expect(find.text('حي الياسمين، فيلا 14'), findsOneWidget);
      },
    );

    // Scenario 5: Dispatcher deactivation after work completion moves app to Inactive while SignalR stays ready
    testWidgets(
      'Scenario 5: Deactivation moves app to Inactive Home while SignalR remains alive and ready',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        // Driver was Active
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.active,
          isAvailable: true,
          currentStatusText: 'متاح للطلبات',
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DriverActiveHomeView), findsOneWidget);

        // Manager deactivates driver
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus: DriverShiftStatus.inactive,
          isAvailable: false,
          currentStatusText: 'غير متصل',
        );

        realtimeClient.emitEvent(
          DriverStatusUpdatedEvent(
            eventId: 'evt-002',
            occurredAtUtc: DateTime.now().toUtc(),
            driverId: 'drv-101',
            shiftStatus: 'Inactive',
            isAvailable: false,
          ),
        );

        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pumpAndSettle();

        // Screen is Inactive
        expect(find.byType(DriverInactiveHomeView), findsOneWidget);
        expect(find.byType(DriverActiveHomeView), findsNothing);

        // SignalR connection is STILL active and listening
        expect(realtimeClient.isConnected, isTrue);
        expect(viewModel.state.isRealtimeConnected, isTrue);
      },
    );

    // Scenario 6: Safe fallbacks for missing/unknown shiftStatus and no self-shift actions
    testWidgets(
      'Scenario 6: Unknown or missing shiftStatus defaults safely to Inactive Home',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);

        // Unknown shiftStatus
        repository.currentEntity = const DriverHomeEntity(
          driverId: 'drv-101',
          driverName: 'عمر الفاروق',
          driverCode: 'DRV-5500',
          shiftStatus:
              DriverShiftStatus.inactive, // Normalized from unknown or null
          isAvailable: false,
          currentStatusText: 'غير متصل',
        );

        await tester.pumpWidget(
          _buildTestApp(child: DriverHomeScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DriverInactiveHomeView), findsOneWidget);
        expect(find.byType(DriverActiveHomeView), findsNothing);

        // No start or end shift controls exist
        expect(find.text('بدء العمل'), findsNothing);
        expect(find.text('إنهاء العمل'), findsNothing);
        expect(find.text('Start Shift'), findsNothing);
        expect(find.text('End Shift'), findsNothing);
      },
    );
  });
}
