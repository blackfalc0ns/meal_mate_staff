import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_realtime_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_filter.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_query_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_orders_repository.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_orders_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/observe_driver_orders_updates_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/start_driver_orders_updates_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/stop_driver_orders_updates_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_orders_event.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_orders_view_model.dart';

class _FakeRealtimeClient implements DriverOrdersRealtimeClient {
  final _eventsController =
      StreamController<DriverOrdersRealtimeEvent>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  int startCalls = 0;
  int stopCalls = 0;

  @override
  Stream<DriverOrdersRealtimeEvent> get events => _eventsController.stream;

  @override
  Stream<bool> get connectionStatus => _connectionController.stream;

  @override
  Future<void> start() async {
    startCalls++;
    _connectionController.add(true);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _connectionController.add(false);
  }

  @override
  bool get isConnected => false;

  @override
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async => null;

  @override
  Future<void> dispose() async {
    await stop();
    await _eventsController.close();
    await _connectionController.close();
  }
}

class _FakeGetDriverOrdersUseCase extends GetDriverOrdersUseCase {
  _FakeGetDriverOrdersUseCase() : super(_StubRepository());

  int callCount = 0;
  DriverOrdersQueryEntity? lastQuery;
  Completer<ApiResult<DriverDeliveryManifestEntity>>? inFlightCompleter;
  ApiResult<DriverDeliveryManifestEntity>? nextResult;

  @override
  Future<ApiResult<DriverDeliveryManifestEntity>> call(
    DriverOrdersQueryEntity query,
  ) async {
    callCount++;
    lastQuery = query;
    if (inFlightCompleter != null) {
      return inFlightCompleter!.future;
    }
    return nextResult ??
        ApiSuccessResult(
          data: DriverDeliveryManifestEntity(
            tripId: 'trip-1',
            tripCode: 'TRP-01',
            totalCount: 0,
            inProgressCount: 0,
            deliveredCount: 0,
            failedCount: 0,
            stops: const [],
          ),
        );
  }
}

class _StubRepository implements DriverOrdersRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeGetDriverOrdersUseCase fakeGetOrders;
  late _FakeRealtimeClient fakeRealtimeClient;
  late ObserveDriverOrdersUpdatesUseCase observeUpdates;
  late StartDriverOrdersUpdatesUseCase startUpdates;
  late StopDriverOrdersUpdatesUseCase stopUpdates;
  late DriverOrdersViewModel viewModel;

  const sampleStop1 = DriverDeliveryStopEntity(
    tripStopId: 'ts-1',
    boxId: 'box-1',
    boxCode: 'BX-101',
    sequenceNumber: 1,
    customerName: 'Customer A',
    deliveryZone: 'Zone A',
    formattedAddress: 'Address A',
    mealsCount: 2,
    mealsSummary: '2 Meals',
    deliveryTimeSlot: '09:00',
    status: DriverDeliveryStatus.inProgress,
    statusText: 'In Progress',
    isCurrentStop: true,
    canCompleteDelivery: true,
    canNavigate: true,
    canCallCustomer: true,
  );

  final sampleManifest = DriverDeliveryManifestEntity(
    tripId: 'trip-100',
    tripCode: 'TRP-100',
    tripStatus: 'InProgress',
    tripStatusText: 'On the way',
    totalCount: 2,
    inProgressCount: 2,
    deliveredCount: 0,
    failedCount: 0,
    stops: [sampleStop1],
  );

  setUp(() {
    fakeGetOrders = _FakeGetDriverOrdersUseCase();
    fakeRealtimeClient = _FakeRealtimeClient();
    observeUpdates = ObserveDriverOrdersUpdatesUseCase(fakeRealtimeClient);
    startUpdates = StartDriverOrdersUpdatesUseCase(fakeRealtimeClient);
    stopUpdates = StopDriverOrdersUpdatesUseCase(fakeRealtimeClient);

    viewModel = DriverOrdersViewModel(
      getOrdersUseCase: fakeGetOrders,
      observeUpdatesUseCase: observeUpdates,
      startUpdatesUseCase: startUpdates,
      stopUpdatesUseCase: stopUpdates,
      realtimeClient: fakeRealtimeClient,
    );
  });

  tearDown(() async {
    await viewModel.close();
    await fakeRealtimeClient.dispose();
  });

  group('DriverOrdersViewModel Load & Query Tests', () {
    test('initial state has isInitialLoading true', () {
      expect(viewModel.state.isInitialLoading, true);
      expect(viewModel.state.hasLoadedOnce, false);
      expect(viewModel.state.manifest.isEmpty, true);
    });

    test('LoadDriverOrdersEvent emits success and starts realtime', () async {
      fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);

      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      expect(viewModel.state.isInitialLoading, false);
      expect(viewModel.state.hasLoadedOnce, true);
      expect(viewModel.state.manifest.tripId, 'trip-100');
      expect(viewModel.state.manifest.stops.length, 1);
      expect(fakeRealtimeClient.startCalls, 1);
    });

    test('LoadDriverOrdersEvent initial failure emits failure', () async {
      fakeGetOrders.nextResult = ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Network error',
          exception: const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Network error',
          ),
        ),
      );

      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      expect(viewModel.state.isInitialLoading, false);
      expect(viewModel.state.hasLoadedOnce, false);
      expect(viewModel.state.failure, isNotNull);
    });

    test('Refresh retains in-memory data on failure', () async {
      // First load succeeds
      fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      // Refresh fails
      fakeGetOrders.nextResult = ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Refresh failed',
          exception: const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Refresh failed',
          ),
        ),
      );
      viewModel.add(const RefreshDriverOrdersEvent());
      await pumpEventQueue();

      expect(viewModel.state.isRefreshing, false);
      expect(viewModel.state.manifest.stops.length, 1); // retained!
      expect(viewModel.state.actionFailure, isNotNull);
    });

    test('SearchDriverOrdersEvent is debounced by 300 ms', () async {
      fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      final initialCalls = fakeGetOrders.callCount;

      // Rapidly type 3 times
      viewModel.add(const SearchDriverOrdersEvent('B'));
      viewModel.add(const SearchDriverOrdersEvent('BX'));
      viewModel.add(const SearchDriverOrdersEvent('BX-1'));

      // Immediately after typing, no network call should have fired yet
      expect(fakeGetOrders.callCount, initialCalls);

      // Wait 350 ms for debounce
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(fakeGetOrders.callCount, initialCalls + 1);
      expect(fakeGetOrders.lastQuery?.search, 'BX-1');
    });

    test('Duplicate filter selection does not trigger new request', () async {
      fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      final initialCalls = fakeGetOrders.callCount;

      // Current filter is all; selecting all again should do nothing
      viewModel.add(
        const SelectDriverOrdersFilterEvent(DriverOrdersFilter.all),
      );
      await pumpEventQueue();

      expect(fakeGetOrders.callCount, initialCalls);

      // Selecting different filter triggers call
      viewModel.add(
        const SelectDriverOrdersFilterEvent(DriverOrdersFilter.delivered),
      );
      await pumpEventQueue();

      expect(fakeGetOrders.callCount, initialCalls + 1);
      expect(fakeGetOrders.lastQuery?.filter, DriverOrdersFilter.delivered);
    });

    test(
      'ResetDriverOrdersQueryEvent clears search and resets filter',
      () async {
        fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
        viewModel.add(const LoadDriverOrdersEvent());
        await pumpEventQueue();

        viewModel.add(
          const SelectDriverOrdersFilterEvent(DriverOrdersFilter.failed),
        );
        await pumpEventQueue();

        viewModel.add(const ResetDriverOrdersQueryEvent());
        await pumpEventQueue();

        expect(viewModel.state.query.search, '');
        expect(viewModel.state.query.filter, DriverOrdersFilter.all);
      },
    );
  });

  group('DriverOrdersViewModel Realtime Reducer Tests', () {
    test(
      'box-delivered event patches target stop and updates counts',
      () async {
        fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
        viewModel.add(const LoadDriverOrdersEvent());
        await pumpEventQueue();

        expect(viewModel.state.manifest.inProgressCount, 2);
        expect(viewModel.state.manifest.deliveredCount, 0);

        final deliveredEvent = DriverOrderDeliveredEvent(
          eventId: 'evt-del-1',
          occurredAtUtc: DateTime.now().toUtc(),
          tripId: 'trip-100',
          boxId: 'box-1',
          tripStopId: 'ts-1',
          statusText: 'تم التسليم بنجاح',
          deliveredAtUtc: DateTime.now().toUtc(),
        );

        viewModel.add(DriverOrdersRealtimeReceivedEvent(deliveredEvent));
        await pumpEventQueue();

        final updatedStop = viewModel.state.manifest.stops.first;
        expect(updatedStop.status, DriverDeliveryStatus.delivered);
        expect(updatedStop.statusText, 'تم التسليم بنجاح');
        expect(viewModel.state.manifest.inProgressCount, 1);
        expect(viewModel.state.manifest.deliveredCount, 1);
        expect(viewModel.state.manifest.totalCount, 2);
      },
    );

    test('stale realtime event is ignored', () async {
      fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      final now = DateTime.now().toUtc();

      // Newer event
      viewModel.add(
        DriverOrdersRealtimeReceivedEvent(
          DriverOrderDeliveredEvent(
            eventId: 'evt-new',
            occurredAtUtc: now,
            tripId: 'trip-100',
            boxId: 'box-1',
            tripStopId: 'ts-1',
          ),
        ),
      );
      await pumpEventQueue();

      // Older event (occurred in the past)
      viewModel.add(
        DriverOrdersRealtimeReceivedEvent(
          DriverDeliveryFailedEvent(
            eventId: 'evt-old',
            occurredAtUtc: now.subtract(const Duration(minutes: 5)),
            tripId: 'trip-100',
            boxId: 'box-1',
            tripStopId: 'ts-1',
          ),
        ),
      );
      await pumpEventQueue();

      // Status should remain delivered
      expect(
        viewModel.state.manifest.stops.first.status,
        DriverDeliveryStatus.delivered,
      );
    });

    test('trip-in-transit event updates trip status banner', () async {
      fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
      viewModel.add(const LoadDriverOrdersEvent());
      await pumpEventQueue();

      viewModel.add(
        DriverOrdersRealtimeReceivedEvent(
          DriverTripInTransitEvent(
            eventId: 'evt-trip',
            occurredAtUtc: DateTime.now().toUtc(),
            tripId: 'trip-100',
            tripStatusText: 'خارج للتوصيل الآن',
          ),
        ),
      );
      await pumpEventQueue();

      expect(viewModel.state.manifest.tripStatusText, 'خارج للتوصيل الآن');
    });

    test(
      'unknown box event triggers a refresh instead of fabricating fake data',
      () async {
        fakeGetOrders.nextResult = ApiSuccessResult(data: sampleManifest);
        viewModel.add(const LoadDriverOrdersEvent());
        await pumpEventQueue();

        final callsBefore = fakeGetOrders.callCount;

        // Event for an unknown box
        viewModel.add(
          DriverOrdersRealtimeReceivedEvent(
            DriverOrderDeliveredEvent(
              eventId: 'evt-unknown-box',
              occurredAtUtc: DateTime.now().toUtc(),
              tripId: 'trip-100',
              boxId: 'box-non-existent',
              tripStopId: 'ts-999',
            ),
          ),
        );
        await pumpEventQueue();

        // Triggered refresh
        expect(fakeGetOrders.callCount, callsBefore + 1);
      },
    );
  });
}
