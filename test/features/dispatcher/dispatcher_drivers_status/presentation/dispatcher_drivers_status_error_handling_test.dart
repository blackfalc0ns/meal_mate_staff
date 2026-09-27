import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
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
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_drivers_status_view_model.dart';

class _FakeDriversStatusRepo implements DispatcherDriversStatusRepository {
  ApiResult<DispatcherDriversStatusSummaryEntity>? summaryResult;
  ApiResult<UpdateDriverAvailabilityResultEntity>? toggleResult;

  static const sampleSummary = DispatcherDriversStatusSummaryEntity(
    counts: DispatcherDriversStatusKpisEntity(
      total: 10,
      available: 5,
      inDelivery: 3,
      unavailable: 2,
    ),
    items: [
      DispatcherDriverStatusItemEntity(
        driverId: 'drv-1',
        driverCode: 'DR-1',
        fullName: 'Driver 1',
        isAvailable: true,
        operationalStatus: DispatcherDriverStatusType.available,
      ),
    ],
    pagination: DispatcherDriversPaginationEntity(
      pageNumber: 1,
      pageSize: 15,
      totalItems: 10,
      totalPages: 1,
    ),
  );

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) async {
    return summaryResult ?? const ApiSuccessResult(data: sampleSummary);
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(
    UpdateDriverAvailabilityRequestEntity request,
  ) async {
    return toggleResult ??
        ApiSuccessResult(
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
      const Stream.empty();

  @override
  Future<void> acquireRealtime(String ownerId) async {}

  @override
  Future<void> releaseRealtime(String ownerId) async {}

  @override
  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  ) async => throw UnimplementedError();
}

void main() {
  late _FakeDriversStatusRepo repo;
  late DispatcherDriversStatusViewModel viewModel;

  setUp(() {
    repo = _FakeDriversStatusRepo();
    viewModel = DispatcherDriversStatusViewModel(
      getDriversStatusUseCase: GetDriversStatusUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('Error Handling', () {
    test(
      '401/403/404 initial load failure sets initialFailure and no summary',
      () async {
        repo.summaryResult = ApiErrorResult(
          failure: Failure(errorMessage: 'Unauthorized', code: '401'),
        );

        await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());

        expect(viewModel.state.initialFailure, isNotNull);
        expect(viewModel.state.initialFailure?.errorMessage, 'Unauthorized');
        expect(viewModel.state.summary, isNull);
        expect(viewModel.state.isInitialLoading, isFalse);
      },
    );

    test(
      'Refresh failure retains existing summary and exposes actionFailure',
      () async {
        // First load succeeds
        await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
        expect(viewModel.state.summary, isNotNull);

        // Refresh fails
        repo.summaryResult = ApiErrorResult(
          failure: Failure(errorMessage: 'Network timeout', code: 'timeout'),
        );
        await viewModel.doIntent(const RefreshDispatcherDriversStatusEvent());

        expect(viewModel.state.summary, isNotNull);
        expect(viewModel.state.summary?.items.length, 1);
        expect(viewModel.state.actionFailure, isNotNull);
        expect(viewModel.state.actionFailure?.errorMessage, 'Network timeout');
        expect(viewModel.state.isRefreshing, isFalse);
      },
    );

    test(
      'PATCH failure restores driver snapshot and exposes actionFailure',
      () async {
        await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());
        final originalItem = viewModel.state.summary!.items.first;
        expect(originalItem.isAvailable, isTrue);

        repo.toggleResult = ApiErrorResult(
          failure: Failure(errorMessage: 'Driver not found', code: '404'),
        );

        await viewModel.doIntent(const ToggleDriverStatusEvent('drv-1', false));

        // After failure, snapshot is restored
        final restoredItem = viewModel.state.summary!.items.first;
        expect(restoredItem.isAvailable, isTrue);
        expect(
          restoredItem.operationalStatus,
          DispatcherDriverStatusType.available,
        );
        expect(viewModel.state.actionFailure, isNotNull);
        expect(viewModel.state.actionFailure?.errorMessage, 'Driver not found');
        expect(viewModel.state.togglingDriverIds.contains('drv-1'), isFalse);
      },
    );

    test('Successful empty response does not set failure', () async {
      repo.summaryResult = const ApiSuccessResult(
        data: DispatcherDriversStatusSummaryEntity(
          counts: DispatcherDriversStatusKpisEntity(
            total: 0,
            available: 0,
            inDelivery: 0,
            unavailable: 0,
          ),
          items: [],
          pagination: DispatcherDriversPaginationEntity(
            pageNumber: 1,
            pageSize: 15,
            totalItems: 0,
            totalPages: 0,
          ),
        ),
      );

      await viewModel.doIntent(const LoadDispatcherDriversStatusEvent());

      expect(viewModel.state.initialFailure, isNull);
      expect(viewModel.state.actionFailure, isNull);
      expect(viewModel.state.summary?.items.isEmpty, isTrue);
    });
  });
}
