import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/auth/data/models/request/phone_lookup_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/data/data_source/dispatcher_orders_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/repo/dispatcher_orders_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/domain/usecase/get_dispatcher_order_queue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_orders/presentation/manager/dispatcher_orders_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_connection_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/start_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/stop_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_support_issues_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/data/data_source/driver_performance_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/repo/driver_performance_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_comparison_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/usecase/get_driver_performance_overview_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/manager/driver_performance_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/data/data_source/operations_log_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'configureDependencies exposes one Dio and one ApiServices sharing the same Dio graph',
    () async {
      await configureDependencies();

      expect(getIt.isRegistered<Dio>(), isTrue);
      expect(getIt.isRegistered<ApiServices>(), isTrue);

      final dio = getIt<Dio>();
      final apiServices = getIt<ApiServices>();

      expect(dio, isNotNull);
      expect(apiServices, isNotNull);

      bool intercepted = false;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            intercepted = true;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'exists': true, 'isFirstTimeSetup': false},
              ),
            );
          },
        ),
      );

      final result = await apiServices.lookupPhone(
        const PhoneLookupRequestDto(phone: '+966500000000', role: 'Driver'),
      );

      expect(intercepted, isTrue);
      expect(result.exists, isTrue);
    },
  );

  test(
    'configureDependencies registers dispatcher orders dependencies',
    () async {
      await configureDependencies();

      expect(getIt.isRegistered<DispatcherOrdersRemoteDataSource>(), isTrue);
      expect(getIt.isRegistered<DispatcherOrdersRepository>(), isTrue);
      expect(getIt.isRegistered<GetDispatcherOrderQueueUseCase>(), isTrue);
      expect(getIt.isRegistered<DispatcherOrdersViewModel>(), isTrue);

      final remoteDataSource = getIt<DispatcherOrdersRemoteDataSource>();
      final repository = getIt<DispatcherOrdersRepository>();
      final useCase = getIt<GetDispatcherOrderQueueUseCase>();
      final viewModel = getIt<DispatcherOrdersViewModel>();

      expect(remoteDataSource, isNotNull);
      expect(repository, isNotNull);
      expect(useCase, isNotNull);
      expect(viewModel, isNotNull);
    },
  );

  test('configureDependencies registers dispatcher map dependencies', () async {
    await configureDependencies();

    expect(getIt.isRegistered<DispatcherMapRealtimeClient>(), isTrue);
    expect(getIt.isRegistered<DispatcherMapRemoteDataSource>(), isTrue);
    expect(getIt.isRegistered<DispatcherMapRepository>(), isTrue);
    expect(getIt.isRegistered<GetDispatcherLiveMonitoringUseCase>(), isTrue);
    expect(getIt.isRegistered<ObserveDispatcherMapUpdatesUseCase>(), isTrue);
    expect(
      getIt.isRegistered<ObserveDispatcherMapConnectionStatusUseCase>(),
      isTrue,
    );
    expect(getIt.isRegistered<StartDispatcherMapUpdatesUseCase>(), isTrue);
    expect(getIt.isRegistered<StopDispatcherMapUpdatesUseCase>(), isTrue);
    expect(getIt.isRegistered<DispatcherMapViewModel>(), isTrue);

    final realtimeClient = getIt<DispatcherMapRealtimeClient>();
    final remoteDataSource = getIt<DispatcherMapRemoteDataSource>();
    final repository = getIt<DispatcherMapRepository>();
    final liveUseCase = getIt<GetDispatcherLiveMonitoringUseCase>();
    final viewModel = getIt<DispatcherMapViewModel>();

    expect(realtimeClient, isNotNull);
    expect(remoteDataSource, isNotNull);
    expect(repository, isNotNull);
    expect(liveUseCase, isNotNull);
    expect(viewModel, isNotNull);
  });

  test(
    'configureDependencies registers dispatcher support dependencies',
    () async {
      await configureDependencies();

      expect(getIt.isRegistered<DispatcherSupportRemoteDataSource>(), isTrue);
      expect(getIt.isRegistered<DispatcherSupportRepository>(), isTrue);
      expect(getIt.isRegistered<GetDispatcherSupportIssuesUseCase>(), isTrue);
      expect(getIt.isRegistered<DispatcherSupportViewModel>(), isTrue);

      final remoteDataSource = getIt<DispatcherSupportRemoteDataSource>();
      final repository = getIt<DispatcherSupportRepository>();
      final useCase = getIt<GetDispatcherSupportIssuesUseCase>();
      final vm1 = getIt<DispatcherSupportViewModel>();
      final vm2 = getIt<DispatcherSupportViewModel>();

      expect(remoteDataSource, isNotNull);
      expect(repository, isNotNull);
      expect(useCase, isNotNull);
      expect(vm1, isNotNull);
      expect(identical(vm1, vm2), isFalse); // factory
    },
  );

  test(
    'configureDependencies registers driver performance dependencies',
    () async {
      await configureDependencies();

      expect(getIt.isRegistered<DriverPerformanceRemoteDataSource>(), isTrue);
      expect(getIt.isRegistered<DriverPerformanceRepository>(), isTrue);
      expect(getIt.isRegistered<GetDriverPerformanceOverviewUseCase>(), isTrue);
      expect(
        getIt.isRegistered<GetDriverPerformanceComparisonUseCase>(),
        isTrue,
      );
      expect(getIt.isRegistered<DriverPerformanceViewModel>(), isTrue);

      final remoteDataSource = getIt<DriverPerformanceRemoteDataSource>();
      final repository = getIt<DriverPerformanceRepository>();
      final overviewUseCase = getIt<GetDriverPerformanceOverviewUseCase>();
      final comparisonUseCase = getIt<GetDriverPerformanceComparisonUseCase>();
      final vm1 = getIt<DriverPerformanceViewModel>();
      final vm2 = getIt<DriverPerformanceViewModel>();

      expect(remoteDataSource, isNotNull);
      expect(repository, isNotNull);
      expect(overviewUseCase, isNotNull);
      expect(comparisonUseCase, isNotNull);
      expect(vm1, isNotNull);
      expect(identical(vm1, vm2), isFalse); // factory
    },
  );

  test(
    'configureDependencies registers operations log dependencies',
    () async {
      await configureDependencies();

      expect(getIt.isRegistered<OperationsLogRemoteDataSource>(), isTrue);
      expect(getIt.isRegistered<OperationsLogRepository>(), isTrue);
      expect(getIt.isRegistered<GetOperationsLogUseCase>(), isTrue);
      expect(getIt.isRegistered<OperationsViewModel>(), isTrue);

      final remoteDataSource = getIt<OperationsLogRemoteDataSource>();
      final repository = getIt<OperationsLogRepository>();
      final useCase = getIt<GetOperationsLogUseCase>();
      final vm1 = getIt<OperationsViewModel>();
      final vm2 = getIt<OperationsViewModel>();

      expect(remoteDataSource, isNotNull);
      expect(repository, isNotNull);
      expect(useCase, isNotNull);
      expect(vm1, isNotNull);
      expect(identical(vm1, vm2), isFalse); // factory
    },
  );
}
