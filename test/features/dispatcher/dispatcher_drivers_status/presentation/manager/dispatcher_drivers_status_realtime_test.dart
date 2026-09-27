import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_drivers_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/observe_driver_availability_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/start_dispatcher_drivers_status_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/stop_dispatcher_drivers_status_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart';

class RealtimeTestRepo extends Fake
    implements DispatcherDriversStatusRepository {
  // ignore: close_sinks
  final updatesController =
      StreamController<UpdateDriverAvailabilityResultEntity>.broadcast();

  int getDriversStatusCalls = 0;
  List<String> acquired = [];
  List<String> released = [];

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      updatesController.stream;

  @override
  Future<void> acquireRealtime(String ownerId) async {
    acquired.add(ownerId);
  }

  @override
  Future<void> releaseRealtime(String ownerId) async {
    released.add(ownerId);
  }

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) async {
    getDriversStatusCalls++;
    return const ApiSuccessResult(
      data: DispatcherDriversStatusSummaryEntity(
        counts: DispatcherDriversStatusKpisEntity(
          total: 2,
          available: 2,
          inDelivery: 0,
          unavailable: 0,
        ),
        items: [
          DispatcherDriverStatusItemEntity(
            driverId: 'd-1',
            driverCode: 'DR-1',
            fullName: 'Driver 1',
            isAvailable: true,
            operationalStatus: DispatcherDriverStatusType.available,
          ),
          DispatcherDriverStatusItemEntity(
            driverId: 'd-2',
            driverCode: 'DR-2',
            fullName: 'Driver 2',
            isAvailable: true,
            operationalStatus: DispatcherDriverStatusType.available,
          ),
        ],
      ),
    );
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(
    UpdateDriverAvailabilityRequestEntity request,
  ) async {
    return ApiSuccessResult(
      data: UpdateDriverAvailabilityResultEntity(
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
  late RealtimeTestRepo repo;
  late DispatcherDriversStatusViewModel viewModel;

  setUp(() {
    repo = RealtimeTestRepo();
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: GetDriversStatusUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
      observeDriverAvailabilityUpdatesUseCase:
          ObserveDriverAvailabilityUpdatesUseCase(repo),
      startUpdatesUseCase: StartDispatcherDriversStatusUpdatesUseCase(repo),
      stopUpdatesUseCase: StopDispatcherDriversStatusUpdatesUseCase(repo),
    );
  });

  tearDown(() async {
    await viewModel.close();
    await repo.updatesController.close();
  });

  test('acquires realtime on load and releases on close', () async {
    await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
    expect(repo.acquired, contains('dispatcher-drivers-status'));

    await viewModel.close();
    expect(repo.released, contains('dispatcher-drivers-status'));
  });

  test(
    'realtime event updates visible driver and counts without full GET',
    () async {
      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
      expect(repo.getDriversStatusCalls, 1);

      // Emit event for visible driver d-1
      repo.updatesController.add(
        const UpdateDriverAvailabilityResultEntity(
          driverId: 'd-1',
          isAvailable: false,
          operationalStatus: DispatcherDriverStatusType.unavailable,
        ),
      );

      // Allow event loop to process stream
      await pumpEventQueue();

      expect(repo.getDriversStatusCalls, 1); // No new GET call!
      final driver1 = viewModel.state.summary!.items.firstWhere(
        (d) => d.driverId == 'd-1',
      );
      expect(driver1.isAvailable, isFalse);
      expect(driver1.operationalStatus, DispatcherDriverStatusType.unavailable);

      expect(viewModel.state.summary!.counts.available, 1);
      expect(viewModel.state.summary!.counts.unavailable, 1);
    },
  );

  test(
    'realtime event for unknown driver outside page triggers debounced refresh',
    () async {
      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
      expect(repo.getDriversStatusCalls, 1);

      // Emit event for driver d-99 (not on page)
      repo.updatesController.add(
        const UpdateDriverAvailabilityResultEntity(
          driverId: 'd-99',
          isAvailable: false,
          operationalStatus: DispatcherDriverStatusType.unavailable,
        ),
      );

      await pumpEventQueue();
      // Wait for the 300ms debounce
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(repo.getDriversStatusCalls, 2); // Refresh triggered!
    },
  );
}
