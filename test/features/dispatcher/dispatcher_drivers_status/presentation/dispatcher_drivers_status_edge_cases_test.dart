import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_pagination_entity.dart';
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

class _FakeDriversStatusRepo implements DispatcherDriversStatusRepository {
  DispatcherDriversStatusQueryEntity? lastQuery;
  int getCallsCount = 0;
  final StreamController<UpdateDriverAvailabilityResultEntity>
  _realtimeController =
      StreamController<UpdateDriverAvailabilityResultEntity>.broadcast();

  static const edgeCaseSummary = DispatcherDriversStatusSummaryEntity(
    counts: DispatcherDriversStatusKpisEntity(
      total: 1,
      available: 0,
      inDelivery: 0,
      unavailable: 0,
    ),
    items: [
      DispatcherDriverStatusItemEntity(
        driverId: 'drv-sparse',
        driverCode: 'DR-SPARSE',
        fullName: 'Sparse Driver',
        phoneNumber: null,
        avatarUrl: null,
        rating: null,
        ratingsCount: null,
        vehicleModel: null,
        vehiclePlate: null,
        isAvailable: false,
        operationalStatus: DispatcherDriverStatusType.unknown,
      ),
    ],
    pagination: DispatcherDriversPaginationEntity(
      pageNumber: 2,
      pageSize: 15,
      totalItems: 16,
      totalPages: 2,
      hasPreviousPage: true,
      hasNextPage: false,
    ),
  );

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) async {
    lastQuery = query;
    getCallsCount++;
    return const ApiSuccessResult(data: edgeCaseSummary);
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
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      _realtimeController.stream;

  @override
  Future<void> acquireRealtime(String ownerId) async {}

  @override
  Future<void> releaseRealtime(String ownerId) async {}

  @override
  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  ) async => throw UnimplementedError();

  void emitRealtime(UpdateDriverAvailabilityResultEntity event) {
    _realtimeController.add(event);
  }

  Future<void> dispose() async {
    await _realtimeController.close();
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
      observeDriverAvailabilityUpdatesUseCase:
          ObserveDriverAvailabilityUpdatesUseCase(repo),
      startUpdatesUseCase: StartDispatcherDriversStatusUpdatesUseCase(repo),
      stopUpdatesUseCase: StopDispatcherDriversStatusUpdatesUseCase(repo),
    );
  });

  tearDown(() async {
    await viewModel.close();
    await repo.dispose();
  });

  group('Edge Cases', () {
    test(
      'Sparse item with all nullable fields renders safely in state',
      () async {
        await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());

        final item = viewModel.state.summary!.items.first;
        expect(item.phoneNumber, isNull);
        expect(item.avatarUrl, isNull);
        expect(item.rating, isNull);
        expect(item.ratingsCount, isNull);
        expect(item.vehicleModel, isNull);
        expect(item.vehiclePlate, isNull);
        expect(item.operationalStatus, DispatcherDriverStatusType.unknown);
      },
    );

    test('Filter change resets pageNumber to 1', () async {
      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
      // Explicitly navigate to page 2
      await viewModel.doIntent(const ChangeDriversStatusPageEvent(2));
      expect(viewModel.state.query.pageNumber, 2);

      // Now change filter
      await viewModel.doIntent(
        const FilterDriversStatusEvent(DispatcherDriverStatusType.available),
      );
      expect(viewModel.state.query.pageNumber, 1);
      expect(
        viewModel.state.query.status,
        DispatcherDriverStatusType.available,
      );
    });

    test('Search query change resets pageNumber to 1 after debounce', () async {
      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
      await viewModel.doIntent(const ChangeDriversStatusPageEvent(2));
      expect(viewModel.state.query.pageNumber, 2);

      await viewModel.doIntent(const SearchDriversStatusEvent('احمد'));
      // Wait for 350ms search debounce
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(viewModel.state.query.pageNumber, 1);
      expect(viewModel.state.query.search, 'احمد');
    });

    test(
      'Realtime update for driver absent from current page triggers debounced refresh',
      () async {
        await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
        final initialCalls = repo.getCallsCount;

        // Emit realtime update for an unlisted driver
        repo.emitRealtime(
          UpdateDriverAvailabilityResultEntity(
            driverId: 'drv-external-999',
            isAvailable: false,
            operationalStatus: DispatcherDriverStatusType.unavailable,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );

        // Wait for 300ms refresh debounce
        await Future<void>.delayed(const Duration(milliseconds: 450));

        expect(repo.getCallsCount, greaterThan(initialCalls));
      },
    );
  });
}
