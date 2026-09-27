import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_boxes_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_pickup_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_pickup_manifest_repository.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_pickup_manifest_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_pickup_manifest_event.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_pickup_manifest_view_model.dart';

class _MockManifestRepository implements DriverPickupManifestRepository {
  Future<ApiResult<DriverPickupManifestEntity>> Function(
    DriverBoxesFilterType filter,
  )?
  onGetManifest;

  @override
  Future<ApiResult<DriverPickupManifestEntity>> getDriverPickupManifest({
    required DriverBoxesFilterType filter,
  }) {
    return onGetManifest!(filter);
  }
}

void main() {
  late _MockManifestRepository mockRepo;
  late GetDriverPickupManifestUseCase useCase;
  late DriverPickupManifestViewModel viewModel;

  const sampleBox = DriverAssignedBoxEntity(
    boxId: 'box-1',
    boxCode: 'BOX-101',
    customerName: 'User A',
    deliveryZone: 'Al-Narjis',
    mealsCount: 2,
    mealsSummary: '2 Meals',
    deliveryTimeSlot: '12:00-14:00',
    status: DriverBoxDeliveryStatus.pendingScan,
    statusText: 'لم يتم التحميل',
    isPickedUp: false,
  );

  const sampleManifest = DriverPickupManifestEntity(
    tripId: 'trip-1',
    tripCode: 'TRIP-01',
    driverId: 'drv-1',
    driverName: 'Driver One',
    totalBoxesCount: 1,
    totalMealsCount: 2,
    pendingScanBoxesCount: 1,
    pickedUpBoxesCount: 0,
    allBoxesPickedUp: false,
    canStartTrip: false,
    boxes: [sampleBox],
  );

  const emptyManifest = DriverPickupManifestEntity(
    tripId: 'trip-1',
    tripCode: 'TRIP-01',
    driverId: 'drv-1',
    driverName: 'Driver One',
    totalBoxesCount: 0,
    totalMealsCount: 0,
    pendingScanBoxesCount: 0,
    pickedUpBoxesCount: 0,
    allBoxesPickedUp: false,
    canStartTrip: false,
    boxes: [],
  );

  setUp(() {
    mockRepo = _MockManifestRepository();
    useCase = GetDriverPickupManifestUseCase(mockRepo);
    viewModel = DriverPickupManifestViewModel(getManifestUseCase: useCase);
  });

  tearDown(() {
    viewModel.close();
  });

  group('DriverPickupManifestViewModel', () {
    test('initial load emits loading then success', () async {
      mockRepo.onGetManifest = (_) async =>
          const ApiSuccessResult(data: sampleManifest);

      final expectation = expectLater(
        viewModel.stream,
        emitsInOrder([
          predicate<dynamic>(
            (s) => s.isInitialLoading == true && s.manifest == null,
          ),
          predicate<dynamic>(
            (s) =>
                s.isInitialLoading == false &&
                s.manifest == sampleManifest &&
                s.hasLoadedOnce == true,
          ),
        ]),
      );

      await viewModel.doIntent(const LoadDriverPickupManifestEvent());
      await expectation;
    });

    test('filter change emits isFilterLoading then updated manifest', () async {
      mockRepo.onGetManifest = (_) async =>
          const ApiSuccessResult(data: sampleManifest);

      await viewModel.doIntent(const LoadDriverPickupManifestEvent());

      final expectation = expectLater(
        viewModel.stream,
        emitsInOrder([
          predicate<dynamic>(
            (s) =>
                s.selectedFilter == DriverBoxesFilterType.pickedUp &&
                s.isFilterLoading == true,
          ),
          predicate<dynamic>(
            (s) =>
                s.selectedFilter == DriverBoxesFilterType.pickedUp &&
                s.isFilterLoading == false &&
                s.manifest == sampleManifest,
          ),
        ]),
      );

      await viewModel.doIntent(
        const SelectDriverBoxesFilterEvent(DriverBoxesFilterType.pickedUp),
      );
      await expectation;
    });

    test('stale request suppression ignores out-of-order responses', () async {
      final completer1 = Completer<ApiResult<DriverPickupManifestEntity>>();
      final completer2 = Completer<ApiResult<DriverPickupManifestEntity>>();

      var callIndex = 0;
      mockRepo.onGetManifest = (filter) {
        callIndex++;
        if (callIndex == 1) return completer1.future;
        return completer2.future;
      };

      // Start initial load (generation 1)
      final future1 = viewModel.doIntent(const LoadDriverPickupManifestEvent());

      // Trigger filter change immediately (generation 2)
      final future2 = viewModel.doIntent(
        const SelectDriverBoxesFilterEvent(DriverBoxesFilterType.pendingScan),
      );

      // Complete request 2 first
      completer2.complete(const ApiSuccessResult(data: sampleManifest));
      await future2;

      expect(viewModel.state.manifest, sampleManifest);
      expect(viewModel.state.selectedFilter, DriverBoxesFilterType.pendingScan);

      // Now complete request 1 with emptyManifest (stale response)
      completer1.complete(const ApiSuccessResult(data: emptyManifest));
      await future1;

      // Manifest should NOT be overwritten by the stale generation 1 response
      expect(viewModel.state.manifest, sampleManifest);
    });

    test(
      'refresh failure retains existing manifest with inline failure',
      () async {
        mockRepo.onGetManifest = (_) async =>
            const ApiSuccessResult(data: sampleManifest);

        await viewModel.doIntent(const LoadDriverPickupManifestEvent());
        expect(viewModel.state.manifest, sampleManifest);

        mockRepo.onGetManifest = (_) async => ApiErrorResult(
          failure: ServerFailure(
            errorMessage: 'Network error',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Network error',
            ),
          ),
        );

        await viewModel.doIntent(const RefreshDriverPickupManifestEvent());

        expect(viewModel.state.manifest, sampleManifest);
        expect(viewModel.state.isRefreshLoading, false);
        expect(viewModel.state.failure, isNotNull);
      },
    );

    test('retry loads data again', () async {
      mockRepo.onGetManifest = (_) async => ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Initial error',
          exception: const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Initial error',
          ),
        ),
      );

      await viewModel.doIntent(const LoadDriverPickupManifestEvent());
      expect(viewModel.state.failure, isNotNull);
      expect(viewModel.state.manifest, isNull);

      mockRepo.onGetManifest = (_) async =>
          const ApiSuccessResult(data: sampleManifest);

      await viewModel.doIntent(const RetryDriverPickupManifestEvent());

      expect(viewModel.state.failure, isNull);
      expect(viewModel.state.manifest, sampleManifest);
    });

    test('empty success manifest updates state correctly', () async {
      mockRepo.onGetManifest = (_) async =>
          const ApiSuccessResult(data: emptyManifest);

      await viewModel.doIntent(const LoadDriverPickupManifestEvent());

      expect(viewModel.state.manifest?.boxes, isEmpty);
      expect(viewModel.state.failure, isNull);
      expect(viewModel.state.isInitialLoading, false);
    });
  });
}
