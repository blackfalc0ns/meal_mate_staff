import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/services/idempotency_key_factory.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_summary_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_trip_start_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/start_driver_trip_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/repo/driver_pickup_repository.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/get_driver_pickup_summary_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/start_driver_trip_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_summary_event.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_summary_view_model.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_action_button.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_shimmer.dart';

import '../../../../support/fakes/fake_driver_pickup_location_provider.dart';

class _FakePickupSummaryRepo implements DriverPickupRepository {
  ApiResult<DriverPickupSummaryEntity>? summaryResult;
  Completer<ApiResult<DriverPickupSummaryEntity>>? summaryCompleter;
  ApiResult<DriverTripStartEntity>? startResult;

  int startCalls = 0;

  @override
  Future<ApiResult<DriverPickupSummaryEntity>> getDriverPickupSummary(
    String tripId,
  ) async {
    if (summaryCompleter != null) return summaryCompleter!.future;
    return summaryResult!;
  }

  @override
  Future<ApiResult<DriverTripStartEntity>> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestEntity request,
  }) async {
    startCalls++;
    return startResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedKeyFactory implements IdempotencyKeyFactory {
  @override
  String create() => 'test-trip-key';
}

void main() {
  late _FakePickupSummaryRepo fakeRepo;
  late DriverPickupSummaryViewModel viewModel;

  const sampleSummary = DriverPickupSummaryEntity(
    tripId: 'trip-101',
    tripCode: 'TRIP-101',
    driverId: 'drv-1',
    driverName: 'Driver Name',
    assignedBoxesCount: 2,
    validatedBoxesCount: 2,
    receivedBoxesCount: 2,
    totalBoxesCount: 2,
    pickedUpBoxesCount: 2,
    allBoxesPickedUp: true,
    canStartTrip: true,
    boxes: [
      DriverPickupSummaryBoxEntity(
        boxId: 'box-1',
        boxCode: 'BOX-REAL-1',
        customerName: 'Ahmad',
        deliveryZone: 'Hawalli',
        mealsCount: 2,
        status: 'PickedUp',
        statusText: 'Picked Up',
        isReceived: true,
      ),
      DriverPickupSummaryBoxEntity(
        boxId: 'box-2',
        boxCode: 'BOX-REAL-2',
        customerName: 'Sara',
        deliveryZone: 'Salmiya',
        mealsCount: 3,
        status: 'PickedUp',
        statusText: 'Picked Up',
        isReceived: true,
      ),
    ],
  );

  const sampleStartResult = DriverTripStartEntity(
    tripId: 'trip-101',
    tripCode: 'TRIP-101',
    status: 'InTransit',
    statusText: 'In Transit',
    activeRouteId: 'route-101',
    startedAtUtc: null,
    message: 'Trip started successfully',
  );

  setUp(() {
    fakeRepo = _FakePickupSummaryRepo();
    viewModel = DriverPickupSummaryViewModel(
      getSummaryUseCase: GetDriverPickupSummaryUseCase(fakeRepo),
      startTripUseCase: StartDriverTripUseCase(fakeRepo),
      locationProvider: FakeDriverPickupLocationProvider(),
      idempotencyKeyFactory: _FixedKeyFactory(),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  Widget buildScreen({
    String tripId = 'trip-101',
    NavigatorObserver? observer,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      navigatorObservers: observer != null ? [observer] : [],
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.driverStartDeliveryRoute) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Text('Driver Start Delivery Route Screen'),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              DriverBoxesReceivedScreen(tripId: tripId, viewModel: viewModel),
        );
      },
    );
  }

  Future<void> sendIntent(
    WidgetTester tester,
    DriverPickupSummaryEvent event,
  ) async {
    await tester.runAsync(() async {
      viewModel.doIntent(event);
      await pumpEventQueue();
    });
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('DriverBoxesReceivedScreen Backend Integration', () {
    testWidgets('shows DriverBoxesReceivedShimmer during initial loading', (
      tester,
    ) async {
      fakeRepo.summaryCompleter = Completer();
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(DriverBoxesReceivedShimmer), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows ApiErrorWidget on initial load failure and retries', (
      tester,
    ) async {
      fakeRepo.summaryResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Network timeout', code: 'timeout'),
      );

      await tester.pumpWidget(buildScreen());
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ApiErrorWidget), findsOneWidget);
      expect(find.text('Network timeout'), findsOneWidget);

      // Now set success and tap retry
      fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);
      final retryBtn = find.text('Retry');
      expect(retryBtn, findsOneWidget);
      await tester.tap(retryBtn);
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ApiErrorWidget), findsNothing);
      expect(find.text('BOX-REAL-1'), findsOneWidget);
    });

    testWidgets('shows EmptyStateWidget when summary boxes list is empty', (
      tester,
    ) async {
      fakeRepo.summaryResult = const ApiSuccessResult(
        data: DriverPickupSummaryEntity(
          tripId: 'trip-empty',
          tripCode: 'TRIP-EMPTY',
          driverId: 'drv-1',
          driverName: 'Driver Name',
          assignedBoxesCount: 0,
          validatedBoxesCount: 0,
          receivedBoxesCount: 0,
          totalBoxesCount: 0,
          pickedUpBoxesCount: 0,
          allBoxesPickedUp: false,
          canStartTrip: false,
          boxes: [],
        ),
      );

      await tester.pumpWidget(buildScreen());
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets(
      'renders backend summary boxes and enables action when canStartTrip is true',
      (tester) async {
        fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);

        await tester.pumpWidget(buildScreen());
        await tester.runAsync(() async {
          await pumpEventQueue();
        });
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('BOX-REAL-1'), findsOneWidget);
        expect(find.text('BOX-REAL-2'), findsOneWidget);

        final actionButton = find.byType(DriverBoxesReceivedActionButton);
        expect(actionButton, findsOneWidget);
      },
    );

    testWidgets(
      'shows InlineApiErrorWidget when start trip fails while retaining content',
      (tester) async {
        fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);
        fakeRepo.startResult = ApiErrorResult(
          failure: Failure(
            errorMessage: 'Start trip failed 500',
            code: 'server_error',
          ),
        );

        await tester.pumpWidget(buildScreen());
        await tester.runAsync(() async {
          await pumpEventQueue();
        });
        await tester.pump(const Duration(milliseconds: 100));

        await sendIntent(tester, const StartDriverTripEvent());

        expect(find.byType(InlineApiErrorWidget), findsOneWidget);
        expect(find.text('Start trip failed 500'), findsOneWidget);
        // Boxes content is still visible!
        expect(find.text('BOX-REAL-1'), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to driverStartDeliveryRoute on successful start trip',
      (tester) async {
        fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);
        fakeRepo.startResult = const ApiSuccessResult(data: sampleStartResult);

        await tester.pumpWidget(buildScreen());
        await tester.runAsync(() async {
          await pumpEventQueue();
        });
        await tester.pump(const Duration(milliseconds: 100));

        await sendIntent(tester, const StartDriverTripEvent());
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Driver Start Delivery Route Screen'), findsOneWidget);
      },
    );
  });
}
