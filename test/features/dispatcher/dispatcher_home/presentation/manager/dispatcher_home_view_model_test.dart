import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_alert_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_operations_status_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/entities/dispatcher_home_overview_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/repo/dispatcher_home_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_home_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/domain/usecase/get_dispatcher_live_drivers_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/manager/dispatcher_home_view_model.dart';

void main() {
  test('loads overview and drivers independently', () async {
    final repository = _FakeRepository();
    final viewModel = _viewModel(repository);

    viewModel.doIntent(const DispatcherHomeLoadEvent());
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.overview?.kpis.totalOrdersToday, 10);
    expect(viewModel.state.liveDrivers.single.id, 'driver-1');
    expect(viewModel.state.overviewFailure, isNull);
    expect(viewModel.state.liveDriversFailure, isNull);
    await viewModel.close();
  });

  test('keeps overview content when only live locations fail', () async {
    final repository = _FakeRepository(failDrivers: true);
    final viewModel = _viewModel(repository);

    viewModel.doIntent(const DispatcherHomeLoadEvent());
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.overview, isNotNull);
    expect(viewModel.state.liveDriversFailure, isNotNull);
    expect(viewModel.state.overviewFailure, isNull);
    await viewModel.close();
  });

  test('location retry calls only the location operation', () async {
    final repository = _FakeRepository(failDrivers: true);
    final viewModel = _viewModel(repository);
    viewModel.doIntent(const DispatcherHomeLoadEvent());
    await Future<void>.delayed(Duration.zero);
    final overviewCalls = repository.overviewCalls;

    repository.failDrivers = false;
    viewModel.doIntent(const DispatcherHomeRetryLiveDriversEvent());
    await Future<void>.delayed(Duration.zero);

    expect(repository.overviewCalls, overviewCalls);
    expect(repository.driverCalls, 2);
    expect(viewModel.state.liveDriversFailure, isNull);
    await viewModel.close();
  });
}

DispatcherHomeViewModel _viewModel(_FakeRepository repository) {
  return DispatcherHomeViewModel(
    getOverviewUseCase: GetDispatcherHomeOverviewUseCase(repository),
    getLiveDriversUseCase: GetDispatcherLiveDriversUseCase(repository),
  );
}

class _FakeRepository implements DispatcherHomeRepository {
  _FakeRepository({this.failDrivers = false});
  bool failDrivers;
  int overviewCalls = 0;
  int driverCalls = 0;

  @override
  Future<ApiResult<DispatcherHomeOverviewEntity>> getOverview() async {
    overviewCalls++;
    return ApiSuccessResult(data: _overview);
  }

  @override
  Future<ApiResult<List<DispatcherHomeMapDriverPinEntity>>>
  getLiveDrivers() async {
    driverCalls++;
    if (failDrivers) {
      return ApiErrorResult(
        failure: Failure.fromException(
          const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Map failed',
          ),
        ),
      );
    }
    return const ApiSuccessResult(data: [_driver]);
  }
}

const _overview = DispatcherHomeOverviewEntity(
  restaurant: DispatcherHomeRestaurantEntity(
    id: 'restaurant-1',
    nameAr: 'مطعم',
    nameEn: 'Restaurant',
    role: 'Dispatcher',
  ),
  greeting: DispatcherHomeGreetingEntity(title: 'مرحبًا', subtitle: 'جاهز'),
  kpis: DispatcherHomeKpisEntity(
    totalOrdersToday: 10,
    inDeliveryCount: 2,
    pendingAssignmentCount: 1,
    activeIssuesCount: 0,
  ),
  operationsStatus: DispatcherHomeOperationsStatusEntity(
    completionRate: 70,
    deliveredCount: 7,
    deliveredLabel: '',
    inDeliveryCount: 2,
    inDeliveryLabel: '',
    pendingCount: 1,
    pendingLabel: '',
    cancelledCount: 0,
    cancelledLabel: '',
  ),
  topDrivers: [],
  regions: [],
  activeIssues: DispatcherHomeActiveIssuesEntity(
    count: 0,
    summaryAr: '',
    summaryEn: '',
    items: [],
  ),
);

const _driver = DispatcherHomeMapDriverPinEntity(
  id: 'driver-1',
  fullName: 'Driver',
  phone: '123',
  plateNumber: 'KWT-1',
  statusText: 'Available',
  status: DispatcherHomePinStatus.available,
  avatarUrl: '',
  latitude: 29.3,
  longitude: 48,
  heading: 0,
  speedKmh: 0,
  updatedAtUtc: null,
);
