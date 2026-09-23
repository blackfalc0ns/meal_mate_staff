import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_area_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_sort.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_roster_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/get_dispatcher_drivers_roster_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/presentation/manager/dispatcher_drivers_view_model.dart';

class FakeDriversRepo implements DispatcherDriversRepository {
  ApiResult<DispatcherDriversRosterEntity>? rosterResult;
  ApiResult<DriverAssignmentResultEntity>? assignResult;
  int getRosterCallCount = 0;
  int assignCallCount = 0;
  DispatcherDriversQueryEntity? lastQuery;
  AssignDriverRequestEntity? lastAssignRequest;

  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) async {
    getRosterCallCount++;
    lastQuery = query;
    return rosterResult ??
        const ApiSuccessResult(
          data: DispatcherDriversRosterEntity(
            counts: DispatcherDriversKpiEntity(
              totalCount: 0,
              availableCount: 0,
              busyCount: 0,
            ),
            selectedView: DispatcherDriverViewMode.byArea,
            selectedAreaKey: null,
            selectedAreaName: '',
            sectionTitle: '',
            areas: [],
            drivers: [],
          ),
        );
  }

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) async {
    assignCallCount++;
    lastAssignRequest = request;
    return assignResult ??
        ApiSuccessResult(
          data: DriverAssignmentResultEntity(
            success: true,
            message: 'OK',
            boxId: request.boxId,
            driverId: request.driverId,
          ),
        );
  }
}

void main() {
  late FakeDriversRepo fakeRepo;
  late GetDispatcherDriversRosterUseCase getRosterUseCase;
  late AssignDriverToBoxUseCase assignDriverUseCase;

  const sampleAvailableDriver = DispatcherDriverEntity(
    driverId: '11111111-1111-1111-1111-111111111111',
    driverCode: 'ID:D-1025',
    fullName: 'أحمد إبراهيم',
    rating: 4.9,
    status: DispatcherDriverStatus.available,
    statusText: 'متاح',
    isAvailableForSelection: true,
    activeOrdersCount: 0,
    completedOrdersTodayCount: 14,
    distanceKm: 2.4,
    currentZoneName: 'السالمية',
    currentZoneKey: 'salmiya',
  );

  const sampleBusyDriver = DispatcherDriverEntity(
    driverId: '22222222-2222-2222-2222-222222222222',
    driverCode: 'ID:D-1026',
    fullName: 'محمد السعيد',
    rating: 4.7,
    status: DispatcherDriverStatus.busy,
    statusText: 'مشغول',
    isAvailableForSelection: false,
    activeOrdersCount: 2,
    completedOrdersTodayCount: 10,
    distanceKm: 1.2,
    currentZoneName: 'السالمية',
    currentZoneKey: 'salmiya',
  );

  const sampleRoster = DispatcherDriversRosterEntity(
    counts: DispatcherDriversKpiEntity(
      totalCount: 2,
      availableCount: 1,
      busyCount: 1,
    ),
    selectedView: DispatcherDriverViewMode.byArea,
    selectedAreaKey: 'salmiya',
    selectedAreaName: 'السالمية',
    sectionTitle: 'سائقو السالمية (2)',
    areas: [
      DispatcherDriverAreaEntity(
        name: 'السالمية',
        areaKey: 'salmiya',
        driverCount: 2,
        isSelected: true,
      ),
      DispatcherDriverAreaEntity(
        name: 'حولي',
        areaKey: 'hawally',
        driverCount: 3,
        isSelected: false,
      ),
    ],
    drivers: [sampleAvailableDriver, sampleBusyDriver],
  );

  setUp(() {
    fakeRepo = FakeDriversRepo();
    getRosterUseCase = GetDispatcherDriversRosterUseCase(fakeRepo);
    assignDriverUseCase = AssignDriverToBoxUseCase(fakeRepo);
  });

  DispatcherDriversViewModel createViewModel({
    DispatcherDriversRouteArgs args = const DispatcherDriversRouteArgs.browse(),
  }) {
    return DispatcherDriversViewModel(
      args: args,
      getRosterUseCase: getRosterUseCase,
      assignDriverUseCase: assignDriverUseCase,
    );
  }

  group('DispatcherDriversViewModel Initial Load', () {
    test(
      'initial load in browse mode sets initialLoading and fetches roster',
      () async {
        fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
        final vm = createViewModel();

        expect(vm.state.isInitialLoading, isFalse);
        expect(vm.state.hasLoadedOnce, isFalse);

        await vm.doIntent(const LoadDispatcherDriversEvent());

        expect(vm.state.hasLoadedOnce, isTrue);
        expect(vm.state.isInitialLoading, isFalse);
        expect(vm.state.roster, sampleRoster);
        expect(fakeRepo.getRosterCallCount, 1);
        expect(fakeRepo.lastQuery?.boxId, isNull);
      },
    );

    test('initial load in assignment mode passes boxId in query', () async {
      fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
      final vm = createViewModel(
        args: const DispatcherDriversRouteArgs.assignment(
          boxId: 'a1111111-1111-1111-1111-111111111111',
        ),
      );

      await vm.doIntent(const LoadDispatcherDriversEvent());

      expect(fakeRepo.lastQuery?.boxId, 'a1111111-1111-1111-1111-111111111111');
    });

    test(
      'initial load failure sets initialFailure and clears loading',
      () async {
        fakeRepo.rosterResult = ApiErrorResult(
          failure: Failure(errorMessage: 'Network error'),
        );
        final vm = createViewModel();

        await vm.doIntent(const LoadDispatcherDriversEvent());

        expect(vm.state.isInitialLoading, isFalse);
        expect(vm.state.initialFailure, isNotNull);
        expect(vm.state.roster, isNull);
      },
    );
  });

  group('DispatcherDriversViewModel View & Area Switching', () {
    test(
      'switching to All emits replacementLoading, clears area, and fetches All',
      () async {
        fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
        final vm = createViewModel();
        await vm.doIntent(const LoadDispatcherDriversEvent());

        final future = vm.doIntent(
          const ChangeDispatcherDriversViewEvent(
            DispatcherDriverViewMode.allDrivers,
          ),
        );

        expect(vm.state.query.view, DispatcherDriverViewMode.allDrivers);
        expect(vm.state.query.areaKey, isNull);

        await future;

        expect(vm.state.isReplacementLoading, isFalse);
        expect(fakeRepo.lastQuery?.view, DispatcherDriverViewMode.allDrivers);
        expect(fakeRepo.lastQuery?.areaKey, isNull);
      },
    );

    test(
      'switching area emits replacementLoading and fetches selected area',
      () async {
        fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
        final vm = createViewModel();
        await vm.doIntent(const LoadDispatcherDriversEvent());

        final future = vm.doIntent(
          const ChangeDispatcherDriversAreaEvent('hawally', 'حولي'),
        );

        expect(vm.state.query.areaKey, 'hawally');

        await future;

        expect(vm.state.isReplacementLoading, isFalse);
        expect(fakeRepo.lastQuery?.areaKey, 'hawally');
      },
    );

    test(
      'nonfatal replacement failure preserves previous roster and emits nonFatalFailure',
      () async {
        fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
        final vm = createViewModel();
        await vm.doIntent(const LoadDispatcherDriversEvent());

        fakeRepo.rosterResult = ApiErrorResult(
          failure: Failure(errorMessage: 'Area not found'),
        );

        await vm.doIntent(
          const ChangeDispatcherDriversAreaEvent('hawally', 'حولي'),
        );

        expect(vm.state.isReplacementLoading, isFalse);
        expect(vm.state.roster, isNotNull); // Retains existing roster!
        expect(vm.state.nonFatalFailure, isNotNull);
      },
    );
  });

  group('DispatcherDriversViewModel Sorting', () {
    test('sorting by rating orders descending without calling API', () async {
      fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
      final vm = createViewModel();
      await vm.doIntent(const LoadDispatcherDriversEvent());

      final callCountBefore = fakeRepo.getRosterCallCount;

      await vm.doIntent(
        const ChangeDispatcherDriversSortEvent(
          DispatcherDriverSort.highestRating,
        ),
      );

      expect(vm.state.selectedSort, DispatcherDriverSort.highestRating);
      expect(fakeRepo.getRosterCallCount, callCountBefore);
      expect(
        vm.state.sortedDrivers.first.fullName,
        'أحمد إبراهيم',
      ); // 4.9 > 4.7
    });

    test('sorting by distance orders ascending without calling API', () async {
      fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
      final vm = createViewModel();
      await vm.doIntent(const LoadDispatcherDriversEvent());

      await vm.doIntent(
        const ChangeDispatcherDriversSortEvent(
          DispatcherDriverSort.nearestDistance,
        ),
      );

      expect(vm.state.sortedDrivers.first.distanceKm, 1.2); // 1.2 < 2.4
    });

    test('sorting by load orders ascending without calling API', () async {
      fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
      final vm = createViewModel();
      await vm.doIntent(const LoadDispatcherDriversEvent());

      await vm.doIntent(
        const ChangeDispatcherDriversSortEvent(
          DispatcherDriverSort.leastActiveLoad,
        ),
      );

      expect(vm.state.sortedDrivers.first.activeOrdersCount, 0); // 0 < 2
    });
  });

  group('DispatcherDriversViewModel Assignment Flow', () {
    test('browse mode does not invoke assignUseCase', () async {
      fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
      final vm = createViewModel(
        args: const DispatcherDriversRouteArgs.browse(),
      );
      await vm.doIntent(const LoadDispatcherDriversEvent());

      await vm.doIntent(const AssignRosterDriverEvent(sampleAvailableDriver));

      expect(fakeRepo.assignCallCount, 0);
      expect(vm.state.assigningDriverId, isNull);
    });

    test('assignment mode rejects unavailable driver', () async {
      fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
      final vm = createViewModel(
        args: const DispatcherDriversRouteArgs.assignment(
          boxId: 'a1111111-1111-1111-1111-111111111111',
        ),
      );
      await vm.doIntent(const LoadDispatcherDriversEvent());

      await vm.doIntent(const AssignRosterDriverEvent(sampleBusyDriver));

      expect(fakeRepo.assignCallCount, 0);
      expect(vm.state.assigningDriverId, isNull);
    });

    test(
      'assignment mode invokes assignUseCase on available driver and emits result',
      () async {
        fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
        fakeRepo.assignResult = ApiSuccessResult(
          data: DriverAssignmentResultEntity(
            success: true,
            message: 'تم إسناد السائق بنجاح',
            boxId: 'a1111111-1111-1111-1111-111111111111',
            driverId: sampleAvailableDriver.driverId,
          ),
        );

        final vm = createViewModel(
          args: const DispatcherDriversRouteArgs.assignment(
            boxId: 'a1111111-1111-1111-1111-111111111111',
          ),
        );
        await vm.doIntent(const LoadDispatcherDriversEvent());

        await vm.doIntent(const AssignRosterDriverEvent(sampleAvailableDriver));

        expect(fakeRepo.assignCallCount, 1);
        expect(vm.state.assigningDriverId, isNull);
        expect(vm.state.assignmentResult?.success, isTrue);
        expect(vm.state.assignmentResult?.message, 'تم إسناد السائق بنجاح');
      },
    );

    test(
      'assignment conflict error triggers automatic roster refresh',
      () async {
        fakeRepo.rosterResult = const ApiSuccessResult(data: sampleRoster);
        fakeRepo.assignResult = ApiErrorResult(
          failure: Failure(
            errorMessage: 'البوكس مسند مسبقاً',
            code: '409',
            exception: const ApiException(
              errorType: ApiErrorType.conflict,
              message: 'البوكس مسند مسبقاً',
              statusCode: 409,
            ),
          ),
        );

        final vm = createViewModel(
          args: const DispatcherDriversRouteArgs.assignment(
            boxId: 'a1111111-1111-1111-1111-111111111111',
          ),
        );
        await vm.doIntent(const LoadDispatcherDriversEvent());
        final getRosterCallsBefore = fakeRepo.getRosterCallCount;

        await vm.doIntent(const AssignRosterDriverEvent(sampleAvailableDriver));

        expect(vm.state.assignmentFailure, isNotNull);
        // Automatic refresh on conflict
        expect(fakeRepo.getRosterCallCount, greaterThan(getRosterCallsBefore));
      },
    );
  });
}
