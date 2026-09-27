import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_sort.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_drivers_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart';

class MockDriversStatusRepository extends Fake
    implements DispatcherDriversStatusRepository {
  DispatcherDriversStatusSummaryEntity? summaryResponse;
  Failure? summaryFailure;

  UpdateDriverAvailabilityResultEntity? toggleResponse;
  Failure? toggleFailure;

  DispatcherDriversStatusQueryEntity? lastQuery;
  UpdateDriverAvailabilityRequestEntity? lastToggleRequest;

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) async {
    lastQuery = query;
    if (summaryFailure != null) {
      return ApiErrorResult(failure: summaryFailure!);
    }
    return ApiSuccessResult(
      data:
          summaryResponse ??
          const DispatcherDriversStatusSummaryEntity(
            counts: DispatcherDriversStatusKpisEntity(
              total: 10,
              available: 5,
              inDelivery: 3,
              unavailable: 2,
            ),
            items: [],
          ),
    );
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(
    UpdateDriverAvailabilityRequestEntity request,
  ) async {
    lastToggleRequest = request;
    if (toggleFailure != null) {
      return ApiErrorResult(failure: toggleFailure!);
    }
    return ApiSuccessResult(
      data:
          toggleResponse ??
          UpdateDriverAvailabilityResultEntity(
            driverId: request.driverId,
            isAvailable: request.isAvailable,
            operationalStatus: request.isAvailable
                ? DispatcherDriverStatusType.available
                : DispatcherDriverStatusType.unavailable,
          ),
    );
  }

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      const Stream.empty();

  @override
  Future<void> acquireRealtime(String ownerId) async {}

  @override
  Future<void> releaseRealtime(String ownerId) async {}
}

void main() {
  late MockDriversStatusRepository repo;
  late GetDriversStatusUseCase getDriversStatusUseCase;
  late ToggleDriverAvailabilityUseCase toggleDriverAvailabilityUseCase;
  late DispatcherDriversStatusViewModel viewModel;

  setUp(() {
    repo = MockDriversStatusRepository();
    getDriversStatusUseCase = GetDriversStatusUseCase(repo);
    toggleDriverAvailabilityUseCase = ToggleDriverAvailabilityUseCase(repo);
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: getDriversStatusUseCase,
      toggleDriverAvailabilityUseCase: toggleDriverAvailabilityUseCase,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('Query operations', () {
    test('initial load sets query, emits summary, clears failure', () async {
      repo.summaryResponse = const DispatcherDriversStatusSummaryEntity(
        counts: DispatcherDriversStatusKpisEntity(
          total: 15,
          available: 10,
          inDelivery: 3,
          unavailable: 2,
        ),
        items: [
          DispatcherDriverStatusItemEntity(
            driverId: 'd-1',
            driverCode: 'DR-1',
            fullName: 'أحمد',
            isAvailable: true,
            operationalStatus: DispatcherDriverStatusType.available,
          ),
        ],
        pagination: DispatcherDriversPaginationEntity(
          pageNumber: 1,
          pageSize: 15,
          totalItems: 15,
          totalPages: 1,
        ),
      );

      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.summary?.counts.total, 15);
      expect(viewModel.state.summary?.items.length, 1);
      expect(viewModel.state.initialFailure, isNull);
    });

    test('initial load failure sets initialFailure and no summary', () async {
      repo.summaryFailure = Failure(errorMessage: 'Network error');

      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.initialFailure, isNotNull);
      expect(viewModel.state.summary, isNull);
    });

    test('filter change resets pageNumber to 1', () async {
      await viewModel.doIntent(
        const FilterDriversStatusEvent(DispatcherDriverStatusType.available),
      );

      expect(repo.lastQuery?.status, DispatcherDriverStatusType.available);
      expect(repo.lastQuery?.pageNumber, 1);
      expect(
        viewModel.state.query.status,
        DispatcherDriverStatusType.available,
      );
    });

    test('sort change resets pageNumber to 1', () async {
      await viewModel.doIntent(
        const SortDriversStatusEvent(DispatcherDriversStatusSort.ratingDesc),
      );

      expect(repo.lastQuery?.sortBy, DispatcherDriversStatusSort.ratingDesc);
      expect(repo.lastQuery?.pageNumber, 1);
    });

    test('page change fetches exact page', () async {
      await viewModel.doIntent(const ChangeDriversStatusPageEvent(3));
      expect(repo.lastQuery?.pageNumber, 3);
    });

    test(
      'refresh retains existing content during loading and on failure',
      () async {
        repo.summaryResponse = const DispatcherDriversStatusSummaryEntity(
          counts: DispatcherDriversStatusKpisEntity(
            total: 1,
            available: 1,
            inDelivery: 0,
            unavailable: 0,
          ),
          items: [
            DispatcherDriverStatusItemEntity(
              driverId: 'd-1',
              driverCode: 'DR-1',
              fullName: 'Driver',
              isAvailable: true,
              operationalStatus: DispatcherDriverStatusType.available,
            ),
          ],
        );

        await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
        expect(viewModel.state.summary?.items.length, 1);

        repo.summaryFailure = Failure(errorMessage: 'Refresh error');

        await viewModel.doIntent(const RefreshDispatcherDriversStatusEvent());

        expect(viewModel.state.isRefreshing, isFalse);
        expect(viewModel.state.summary?.items.length, 1); // Content retained!
        expect(viewModel.state.actionFailure, isNotNull); // Action failure!
        expect(
          viewModel.state.initialFailure,
          isNull,
        ); // Initial failure untouched
      },
    );
  });

  group('Availability Toggle', () {
    const driverAvailable = DispatcherDriverStatusItemEntity(
      driverId: 'd-1',
      driverCode: 'DR-1',
      fullName: 'Driver 1',
      isAvailable: true,
      operationalStatus: DispatcherDriverStatusType.available,
    );

    const driverInDelivery = DispatcherDriverStatusItemEntity(
      driverId: 'd-2',
      driverCode: 'DR-2',
      fullName: 'Driver 2',
      isAvailable: true,
      operationalStatus: DispatcherDriverStatusType.inDelivery,
    );

    setUp(() async {
      repo.summaryResponse = const DispatcherDriversStatusSummaryEntity(
        counts: DispatcherDriversStatusKpisEntity(
          total: 2,
          available: 1,
          inDelivery: 1,
          unavailable: 0,
        ),
        items: [driverAvailable, driverInDelivery],
      );
      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
    });

    test(
      'Available -> toggle false: updates status to unavailable and counts',
      () async {
        await viewModel.doIntent(
          const ToggleDriverStatusEvent('d-1', false, reason: 'Break'),
        );

        expect(repo.lastToggleRequest?.driverId, 'd-1');
        expect(repo.lastToggleRequest?.isAvailable, false);
        expect(repo.lastToggleRequest?.reason, 'Break');

        final updatedDriver = viewModel.state.summary!.items.firstWhere(
          (d) => d.driverId == 'd-1',
        );
        expect(updatedDriver.isAvailable, isFalse);
        expect(
          updatedDriver.operationalStatus,
          DispatcherDriverStatusType.unavailable,
        );

        expect(viewModel.state.summary!.counts.available, 0);
        expect(viewModel.state.summary!.counts.unavailable, 1);
      },
    );

    test(
      'InDelivery -> toggle false: isAvailable is false but status remains inDelivery',
      () async {
        repo.toggleResponse = const UpdateDriverAvailabilityResultEntity(
          driverId: 'd-2',
          isAvailable: false,
          operationalStatus: DispatcherDriverStatusType.inDelivery,
        );

        await viewModel.doIntent(const ToggleDriverStatusEvent('d-2', false));

        final updatedDriver = viewModel.state.summary!.items.firstWhere(
          (d) => d.driverId == 'd-2',
        );
        expect(updatedDriver.isAvailable, isFalse);
        expect(
          updatedDriver.operationalStatus,
          DispatcherDriverStatusType.inDelivery,
        );
      },
    );

    test(
      'PATCH failure restores exact snapshot and sets actionFailure',
      () async {
        repo.toggleFailure = Failure(errorMessage: 'Failed to update');

        await viewModel.doIntent(const ToggleDriverStatusEvent('d-1', false));

        final driver = viewModel.state.summary!.items.firstWhere(
          (d) => d.driverId == 'd-1',
        );
        expect(driver.isAvailable, isTrue); // Restored!
        expect(
          driver.operationalStatus,
          DispatcherDriverStatusType.available,
        ); // Restored!
        expect(viewModel.state.summary!.counts.available, 1); // Restored!
        expect(viewModel.state.summary!.counts.unavailable, 0); // Restored!

        expect(viewModel.state.actionFailure, isNotNull);
        expect(viewModel.state.initialFailure, isNull);
      },
    );
  });
}
