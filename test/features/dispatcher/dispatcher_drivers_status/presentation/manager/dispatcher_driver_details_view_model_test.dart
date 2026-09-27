import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_dispatcher_driver_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/observe_dispatcher_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/start_dispatcher_drivers_status_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/stop_dispatcher_drivers_status_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_driver_details_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_driver_details_view_model.dart';

class MockDetailsRepo extends Fake
    implements DispatcherDriversStatusRepository {
  DispatcherDriverDetailsEntity? mockDetails;
  Failure? detailsFailure;

  UpdateDriverAvailabilityResultEntity? mockToggle;
  Failure? toggleFailure;

  // ignore: close_sinks
  final updatesController =
      StreamController<UpdateDriverAvailabilityResultEntity>.broadcast();

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      updatesController.stream;

  @override
  Future<void> acquireRealtime(String ownerId) async {}

  @override
  Future<void> releaseRealtime(String ownerId) async {}

  @override
  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  ) async {
    if (detailsFailure != null) {
      return ApiErrorResult(failure: detailsFailure!);
    }
    return ApiSuccessResult(
      data:
          mockDetails ??
          DispatcherDriverDetailsEntity(
            id: driverId,
            name: 'أحمد',
            code: 'DR-1',
            isAvailable: true,
            operationalStatus: DispatcherDriverStatusType.available,
          ),
    );
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(
    UpdateDriverAvailabilityRequestEntity request,
  ) async {
    if (toggleFailure != null) {
      return ApiErrorResult(failure: toggleFailure!);
    }
    return ApiSuccessResult(
      data:
          mockToggle ??
          UpdateDriverAvailabilityResultEntity(
            driverId: request.driverId,
            isAvailable: request.isAvailable,
            operationalStatus: request.isAvailable
                ? DispatcherDriverStatusType.available
                : DispatcherDriverStatusType.unavailable,
          ),
    );
  }
}

void main() {
  late MockDetailsRepo repo;
  late DispatcherDriverDetailsViewModel viewModel;

  setUp(() {
    repo = MockDetailsRepo();
    viewModel = DispatcherDriverDetailsViewModel(
      driverId: 'drv-1',
      getDriverDetailsUseCase: GetDispatcherDriverDetailsUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
      observeDriverAvailabilityUseCase:
          ObserveDispatcherDriverAvailabilityUseCase(repo),
      startUpdatesUseCase: StartDispatcherDriversStatusUpdatesUseCase(repo),
      stopUpdatesUseCase: StopDispatcherDriversStatusUpdatesUseCase(repo),
    );
  });

  tearDown(() async {
    await viewModel.close();
    await repo.updatesController.close();
  });

  test('loads driver details on Started event', () async {
    await viewModel.doIntent(const Started('drv-1'));

    expect(viewModel.state.isInitialLoading, isFalse);
    expect(viewModel.state.details?.id, 'drv-1');
    expect(viewModel.state.failure, isNull);
  });

  test('emits initial failure when load fails', () async {
    repo.detailsFailure = Failure(errorMessage: 'Not found');

    await viewModel.doIntent(const Started('drv-1'));

    expect(viewModel.state.isInitialLoading, isFalse);
    expect(viewModel.state.details, isNull);
    expect(viewModel.state.failure, isNotNull);
  });

  test('refresh retains details on failure and sets inlineFailure', () async {
    await viewModel.doIntent(const Started('drv-1'));
    expect(viewModel.state.details, isNotNull);

    repo.detailsFailure = Failure(errorMessage: 'Timeout');

    await viewModel.doIntent(const Refreshed());

    expect(viewModel.state.isRefreshing, isFalse);
    expect(viewModel.state.details, isNotNull); // Retained!
    expect(viewModel.state.inlineFailure, isNotNull);
    expect(viewModel.state.failure, isNull);
  });

  test(
    'availability toggle updates optimistically and reconciles on success',
    () async {
      await viewModel.doIntent(const Started('drv-1'));

      await viewModel.doIntent(
        const AvailabilityChanged(false, reason: 'Break'),
      );

      expect(viewModel.state.details?.isAvailable, isFalse);
      expect(
        viewModel.state.details?.operationalStatus,
        DispatcherDriverStatusType.unavailable,
      );
      expect(viewModel.state.isUpdatingAvailability, isFalse);
    },
  );

  test('availability toggle rolls back on failure', () async {
    await viewModel.doIntent(const Started('drv-1'));

    repo.toggleFailure = Failure(errorMessage: 'Error');

    await viewModel.doIntent(const AvailabilityChanged(false));

    expect(viewModel.state.details?.isAvailable, isTrue); // Rolled back!
    expect(
      viewModel.state.details?.operationalStatus,
      DispatcherDriverStatusType.available,
    );
    expect(viewModel.state.inlineFailure, isNotNull);
  });

  test('realtime availability update is applied to open driver', () async {
    await viewModel.doIntent(const Started('drv-1'));

    repo.updatesController.add(
      const UpdateDriverAvailabilityResultEntity(
        driverId: 'drv-1',
        isAvailable: false,
        operationalStatus: DispatcherDriverStatusType.unavailable,
      ),
    );

    await pumpEventQueue();

    expect(viewModel.state.details?.isAvailable, isFalse);
    expect(
      viewModel.state.details?.operationalStatus,
      DispatcherDriverStatusType.unavailable,
    );
  });
}
