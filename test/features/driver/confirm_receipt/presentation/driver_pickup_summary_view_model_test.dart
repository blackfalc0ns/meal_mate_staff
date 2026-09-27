import 'package:flutter_test/flutter_test.dart';
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

import '../../../../support/fakes/fake_driver_pickup_location_provider.dart';

class _FakePickupSummaryRepo implements DriverPickupRepository {
  ApiResult<DriverPickupSummaryEntity>? summaryResult;
  ApiResult<DriverTripStartEntity>? startResult;

  int startCalls = 0;
  List<String> startIdempotencyKeys = [];

  @override
  Future<ApiResult<DriverPickupSummaryEntity>> getDriverPickupSummary(
    String tripId,
  ) async {
    return summaryResult!;
  }

  @override
  Future<ApiResult<DriverTripStartEntity>> startDriverTrip({
    required String tripId,
    required String idempotencyKey,
    required StartDriverTripRequestEntity request,
  }) async {
    startCalls++;
    startIdempotencyKeys.add(idempotencyKey);
    return startResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedKeyFactory implements IdempotencyKeyFactory {
  int _counter = 0;

  @override
  String create() {
    _counter++;
    return 'trip-key-$_counter';
  }
}

void main() {
  late _FakePickupSummaryRepo fakeRepo;
  late DriverPickupSummaryViewModel viewModel;

  const sampleSummary = DriverPickupSummaryEntity(
    tripId: 'trip-101',
    tripCode: 'TRIP-101',
    driverId: 'drv-1',
    driverName: 'Driver Name',
    assignedBoxesCount: 5,
    validatedBoxesCount: 5,
    receivedBoxesCount: 5,
    totalBoxesCount: 5,
    pickedUpBoxesCount: 5,
    allBoxesPickedUp: true,
    canStartTrip: true,
    boxes: [
      DriverPickupSummaryBoxEntity(
        boxId: 'box-1',
        boxCode: 'BOX-101',
        customerName: 'Customer 1',
        deliveryZone: 'Hawalli',
        mealsCount: 2,
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
    startedAtUtc: null,
    activeRouteId: 'route-101',
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

  tearDown(() {
    viewModel.close();
  });

  group('DriverPickupSummaryViewModel', () {
    test('initial state has no summary and is not loading', () {
      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.summary, isNull);
      expect(viewModel.state.failure, isNull);
      expect(viewModel.state.startTripResult, isNull);
      expect(viewModel.state.canStartTrip, isFalse);
    });

    test('LoadDriverPickupSummaryEvent loads summary successfully', () async {
      fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);

      viewModel.doIntent(const LoadDriverPickupSummaryEvent('trip-101'));
      await pumpEventQueue();

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.summary, sampleSummary);
      expect(viewModel.state.canStartTrip, isTrue);
      expect(viewModel.state.failure, isNull);
    });

    test('LoadDriverPickupSummaryEvent handles failure', () async {
      fakeRepo.summaryResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Network error', code: 'network_error'),
      );

      viewModel.doIntent(const LoadDriverPickupSummaryEvent('trip-101'));
      await pumpEventQueue();

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.summary, isNull);
      expect(viewModel.state.failure?.errorMessage, 'Network error');
    });

    test(
      'StartDriverTripEvent starts trip with location and idempotency key',
      () async {
        fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);
        fakeRepo.startResult = const ApiSuccessResult(data: sampleStartResult);

        viewModel.doIntent(const LoadDriverPickupSummaryEvent('trip-101'));
        await pumpEventQueue();

        viewModel.doIntent(const StartDriverTripEvent());
        await pumpEventQueue();

        expect(fakeRepo.startCalls, 1);
        expect(fakeRepo.startIdempotencyKeys.first, 'trip-key-1');
        expect(viewModel.state.startTripResult, sampleStartResult);
        expect(viewModel.state.isActionLoading, isFalse);
        expect(viewModel.state.failure, isNull);
      },
    );

    test(
      'StartDriverTripEvent retry reuses the same idempotency key',
      () async {
        fakeRepo.summaryResult = const ApiSuccessResult(data: sampleSummary);
        fakeRepo.startResult = ApiErrorResult(
          failure: Failure(errorMessage: 'Server 500', code: 'server_error'),
        );

        viewModel.doIntent(const LoadDriverPickupSummaryEvent('trip-101'));
        await pumpEventQueue();

        // First attempt
        viewModel.doIntent(const StartDriverTripEvent());
        await pumpEventQueue();

        expect(fakeRepo.startCalls, 1);
        expect(fakeRepo.startIdempotencyKeys[0], 'trip-key-1');
        expect(viewModel.state.failure?.errorMessage, 'Server 500');
        // Content remains visible!
        expect(viewModel.state.summary, sampleSummary);

        // Retry attempt
        fakeRepo.startResult = const ApiSuccessResult(data: sampleStartResult);
        viewModel.doIntent(const StartDriverTripEvent());
        await pumpEventQueue();

        expect(fakeRepo.startCalls, 2);
        expect(fakeRepo.startIdempotencyKeys[1], 'trip-key-1'); // Reused!
        expect(viewModel.state.startTripResult, sampleStartResult);
        expect(viewModel.state.failure, isNull);
      },
    );
  });
}
