import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/repo/driver_home_repository.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/usecase/get_driver_home_usecase.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_home_event.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/manager/driver_home_view_model.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_realtime_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';

class _FakeDriverHomeRepository implements DriverHomeRepository {
  ApiResult<DriverHomeEntity>? nextResult;
  int callCount = 0;
  Completer<ApiResult<DriverHomeEntity>>? inFlightCompleter;

  @override
  Future<ApiResult<DriverHomeEntity>> getDriverHome() async {
    callCount++;
    if (inFlightCompleter != null) {
      return inFlightCompleter!.future;
    }
    return nextResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRealtimeClient implements DriverOrdersRealtimeClient {
  final eventController =
      StreamController<DriverOrdersRealtimeEvent>.broadcast();
  final connectionController = StreamController<bool>.broadcast();
  bool isConnectedValue = false;

  @override
  Future<void> start() async {
    isConnectedValue = true;
  }

  @override
  Future<void> stop() async {
    isConnectedValue = false;
  }

  @override
  Future<void> dispose() async {
    await eventController.close();
    await connectionController.close();
  }

  @override
  Stream<DriverOrdersRealtimeEvent> get events => eventController.stream;

  @override
  Stream<bool> get connectionStatus => connectionController.stream;

  @override
  bool get isConnected => isConnectedValue;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DriverHomeViewModel', () {
    late _FakeDriverHomeRepository fakeRepository;
    late GetDriverHomeUseCase useCase;
    late _FakeRealtimeClient fakeRealtimeClient;
    late DriverHomeViewModel viewModel;

    const inactiveHome = DriverHomeEntity(
      driverId: 'drv-1',
      driverName: 'سائق غير متصل',
      driverCode: 'D01',
      shiftStatus: DriverShiftStatus.inactive,
      isAvailable: false,
      currentStatusText: 'غير متصل',
    );

    const activeAvailableHome = DriverHomeEntity(
      driverId: 'drv-1',
      driverName: 'سائق نشط',
      driverCode: 'D01',
      shiftStatus: DriverShiftStatus.active,
      isAvailable: true,
      currentStatusText: 'متاح',
    );

    const activeBusyHome = DriverHomeEntity(
      driverId: 'drv-1',
      driverName: 'سائق نشط ومشغول',
      driverCode: 'D01',
      shiftStatus: DriverShiftStatus.active,
      isAvailable: false,
      currentStatusText: 'مشغول',
      currentDeliveryTask: DriverHomeCurrentDeliveryTaskEntity(
        boxId: 'box-1',
        boxCode: 'BX-1',
        customerName: 'محمد',
        customerPhone: '99887766',
        deliveryAddress: 'حولي',
        destinationLatitude: 29.3,
        destinationLongitude: 48.0,
        mealsCount: 2,
        mealsSummary: '2 وجبات',
        deliveryTimeSlot: '12:00',
        status: 'InTransit',
        deliveryNotes: 'اتصال',
      ),
    );

    setUp(() {
      fakeRepository = _FakeDriverHomeRepository();
      useCase = GetDriverHomeUseCase(fakeRepository);
      fakeRealtimeClient = _FakeRealtimeClient();
      viewModel = DriverHomeViewModel(
        getDriverHomeUseCase: useCase,
        realtimeClient: fakeRealtimeClient,
      );
    });

    tearDown(() async {
      await viewModel.close();
      await fakeRealtimeClient.dispose();
    });

    test(
      'initial load success for Inactive Home sets state correctly',
      () async {
        fakeRepository.nextResult = const ApiSuccessResult(data: inactiveHome);

        await viewModel.doIntent(const DriverHomeLoadStarted());

        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.isRefreshing, false);
        expect(viewModel.state.home, inactiveHome);
        expect(viewModel.state.home?.shiftStatus, DriverShiftStatus.inactive);
        expect(viewModel.state.failure, isNull);
      },
    );

    test('initial load success for Active available Home', () async {
      fakeRepository.nextResult = const ApiSuccessResult(
        data: activeAvailableHome,
      );

      await viewModel.doIntent(const DriverHomeLoadStarted());

      expect(viewModel.state.home, activeAvailableHome);
      expect(viewModel.state.home?.shiftStatus, DriverShiftStatus.active);
      expect(viewModel.state.home?.isAvailable, true);
      expect(viewModel.state.home?.isAvailableAndIdle, true);
    });

    test('Active busy remains Active when isAvailable == false', () async {
      fakeRepository.nextResult = const ApiSuccessResult(data: activeBusyHome);

      await viewModel.doIntent(const DriverHomeLoadStarted());

      expect(viewModel.state.home, activeBusyHome);
      expect(viewModel.state.home?.shiftStatus, DriverShiftStatus.active);
      expect(viewModel.state.home?.isAvailable, false);
      expect(viewModel.state.home?.isBusy, true);
    });

    test(
      'initial load failure stores typed Failure without crashing',
      () async {
        final failure = Failure(errorMessage: 'Connection failed');
        fakeRepository.nextResult = ApiErrorResult(failure: failure);

        await viewModel.doIntent(const DriverHomeLoadStarted());

        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.home, isNull);
        expect(viewModel.state.failure, failure);
        expect(viewModel.state.errorMessage, 'Connection failed');
      },
    );

    test('retry reloads Home', () async {
      final failure = Failure(errorMessage: 'Timeout');
      fakeRepository.nextResult = ApiErrorResult(failure: failure);
      await viewModel.doIntent(const DriverHomeLoadStarted());

      expect(fakeRepository.callCount, 1);
      expect(viewModel.state.home, isNull);

      fakeRepository.nextResult = const ApiSuccessResult(
        data: activeAvailableHome,
      );
      await viewModel.doIntent(const DriverHomeRetryRequested());

      expect(fakeRepository.callCount, 2);
      expect(viewModel.state.home, activeAvailableHome);
      expect(viewModel.state.failure, isNull);
    });

    test(
      'refresh failure retains existing entity and records failure',
      () async {
        fakeRepository.nextResult = const ApiSuccessResult(
          data: activeAvailableHome,
        );
        await viewModel.doIntent(const DriverHomeLoadStarted());
        expect(viewModel.state.home, activeAvailableHome);

        final refreshFailure = Failure(errorMessage: 'Network drop');
        fakeRepository.nextResult = ApiErrorResult(failure: refreshFailure);
        await viewModel.doIntent(const DriverHomeRefreshRequested());

        expect(viewModel.state.isRefreshing, false);
        expect(viewModel.state.home, activeAvailableHome);
        expect(viewModel.state.failure, refreshFailure);
      },
    );

    test(
      'driver-status-updated event triggers Home reload without using payload for display',
      () async {
        fakeRepository.nextResult = const ApiSuccessResult(data: inactiveHome);
        await viewModel.doIntent(const DriverHomeLoadStarted());
        expect(fakeRepository.callCount, 1);

        fakeRepository.nextResult = const ApiSuccessResult(
          data: activeAvailableHome,
        );
        fakeRealtimeClient.eventController.add(
          DriverStatusUpdatedEvent(
            eventId: 'evt-1',
            occurredAtUtc: DateTime.now().toUtc(),
            shiftStatus: 'FakeActiveStatus',
          ),
        );

        // Allow microtask to process
        await pumpEventQueue();

        expect(fakeRepository.callCount, 2);
        expect(viewModel.state.home, activeAvailableHome);
      },
    );

    test('reconnect and resume trigger Home reload', () async {
      fakeRepository.nextResult = const ApiSuccessResult(data: inactiveHome);
      await viewModel.doIntent(const DriverHomeLoadStarted());
      expect(fakeRepository.callCount, 1);

      // Resume
      fakeRepository.nextResult = const ApiSuccessResult(data: inactiveHome);
      await viewModel.doIntent(const DriverHomeLifecycleResumed());
      expect(fakeRepository.callCount, 2);

      // SignalR reconnect transition: false -> true
      fakeRealtimeClient.connectionController.add(false);
      await pumpEventQueue();
      fakeRealtimeClient.connectionController.add(true);
      await pumpEventQueue();

      expect(fakeRepository.callCount, 3);
    });

    test(
      'simultaneous triggers are coalesced and latest refresh is not lost',
      () async {
        final completer1 = Completer<ApiResult<DriverHomeEntity>>();
        fakeRepository.inFlightCompleter = completer1;

        // Start first load (stays in flight)
        final future1 = viewModel.doIntent(const DriverHomeLoadStarted());
        expect(fakeRepository.callCount, 1);

        // Trigger 3 events while first request is in flight
        final future2 = viewModel.doIntent(const DriverHomeRefreshRequested());
        final future3 = viewModel.doIntent(const DriverHomeLifecycleResumed());
        final future4 = viewModel.doIntent(
          const DriverHomeStatusUpdatedReceived(),
        );

        // Still only 1 call dispatched so far
        expect(fakeRepository.callCount, 1);

        // Set second result and complete first request
        fakeRepository.inFlightCompleter = null;
        fakeRepository.nextResult = const ApiSuccessResult(
          data: activeAvailableHome,
        );
        completer1.complete(const ApiSuccessResult(data: inactiveHome));

        await Future.wait([future1, future2, future3, future4]);
        await pumpEventQueue();

        // Exactly 2 calls executed: initial + 1 coalesced follow-up
        expect(fakeRepository.callCount, 2);
        expect(viewModel.state.home, activeAvailableHome);
      },
    );
  });
}
