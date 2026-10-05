import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_navigation_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/repo/driver_map_repository.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/manager/driver_map_event.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/manager/driver_map_view_model.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/tracking/domain/entities/driver_live_location_sample.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';

class _FakeDriverMapRepository implements DriverMapRepository {
  final List<String?> requestedStopIds = [];
  Future<ApiResult<DriverMapRouteEntity>> Function(String? focusedStopId)? onGetRoute;

  DriverMapRouteEntity defaultRoute = const DriverMapRouteEntity(
    tripId: 'trip-1',
    tripCode: 'TRP-1',
    focusedStop: DriverMapStopEntity(
      id: 'stop-1',
      boxCode: 'BX-1',
      customerName: 'User 1',
      area: 'Area 1',
      formattedAddress: 'Address 1',
      mealsCount: 1,
      deliveryTimeSlot: '10:00',
      status: DriverDeliveryStatus.inProgress,
      isCurrent: true,
    ),
    stops: [
      DriverMapStopEntity(
        id: 'stop-1',
        boxCode: 'BX-1',
        customerName: 'User 1',
        area: 'Area 1',
        formattedAddress: 'Address 1',
        mealsCount: 1,
        deliveryTimeSlot: '10:00',
        status: DriverDeliveryStatus.inProgress,
        isCurrent: true,
      ),
      DriverMapStopEntity(
        id: 'stop-2',
        boxCode: 'BX-2',
        customerName: 'User 2',
        area: 'Area 2',
        formattedAddress: 'Address 2',
        mealsCount: 2,
        deliveryTimeSlot: '11:00',
        status: DriverDeliveryStatus.pending,
      ),
    ],
    navigation: DriverMapNavigationEntity(
      destinationStopId: 'stop-1',
      routeStatus: DriverMapRouteStatus.ready,
      canNavigate: true,
      encodedPolyline: 'polyline_sample',
    ),
  );

  @override
  Future<ApiResult<DriverMapRouteEntity>> getDriverMapRoute({String? focusedStopId}) async {
    requestedStopIds.add(focusedStopId);
    if (onGetRoute != null) {
      return onGetRoute!(focusedStopId);
    }
    return ApiSuccessResult(data: defaultRoute);
  }
}

class _FakeCoordinator implements DriverLiveLocationCoordinator {
  final _positionsController = StreamController<DriverLiveLocationSample>.broadcast();
  DriverLiveLocationSample? latestLocationSample;
  DriverLiveLocationSample? lastSuccessfullySentLocationSample;
  int sendCurrentLocationCallCount = 0;

  @override
  DriverLiveLocationSample? get latestLocation => latestLocationSample;

  @override
  Stream<DriverLiveLocationSample> get positions => _positionsController.stream;

  @override
  DriverLiveLocationSample? get lastSuccessfullySentLocation => lastSuccessfullySentLocationSample;

  @override
  Future<bool> sendCurrentLocationNow() async {
    sendCurrentLocationCallCount++;
    return true;
  }

  void emitSample(DriverLiveLocationSample sample) {
    latestLocationSample = sample;
    _positionsController.add(sample);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDriverMapRepository repository;
  late GetDriverMapRouteUseCase useCase;
  late _FakeCoordinator coordinator;
  late DriverMapViewModel viewModel;

  setUp(() {
    repository = _FakeDriverMapRepository();
    useCase = GetDriverMapRouteUseCase(repository);
    coordinator = _FakeCoordinator();

    viewModel = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      pollingInterval: const Duration(milliseconds: 100),
      bootstrapWaitLimit: const Duration(milliseconds: 50),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DriverMapViewModel', () {
    test('initial activation requests route without focus and sets focusedStop selection', () async {
      await viewModel.doIntent(const DriverMapActivated());

      expect(repository.requestedStopIds.length, 1);
      expect(repository.requestedStopIds.first, isNull);
      expect(viewModel.state.selectedStopId, 'stop-1');
      expect(viewModel.state.visibleNavigation, isNotNull);
      expect(viewModel.state.visibleNavigation?.destinationStopId, 'stop-1');
      expect(viewModel.state.isLoading, isFalse);
    });

    test('selecting stop B sends stopId B and clears visibleNavigation immediately', () async {
      await viewModel.doIntent(const DriverMapActivated());

      final selectionCompleter = Completer<ApiResult<DriverMapRouteEntity>>();
      repository.onGetRoute = (id) => selectionCompleter.future;

      // Select stop-2
      final selectFuture = viewModel.doIntent(const DriverMapStopSelected('stop-2'));

      // Check immediate state before response arrives:
      expect(viewModel.state.selectedStopId, 'stop-2');
      expect(viewModel.state.visibleNavigation, isNull); // Cleared immediately!
      expect(viewModel.state.route, isNotNull); // Cards preserved!
      expect(viewModel.state.isRefreshing, isTrue);

      selectionCompleter.complete(
        ApiSuccessResult(
          data: DriverMapRouteEntity(
            tripId: 'trip-1',
            tripCode: 'TRP-1',
            focusedStop: repository.defaultRoute.stops[1],
            stops: repository.defaultRoute.stops,
            navigation: const DriverMapNavigationEntity(
              destinationStopId: 'stop-2',
              routeStatus: DriverMapRouteStatus.ready,
              canNavigate: true,
            ),
          ),
        ),
      );

      await selectFuture;
      expect(viewModel.state.visibleNavigation?.destinationStopId, 'stop-2');
      expect(viewModel.state.isRefreshing, isFalse);
    });

    test('slow response for stop A arriving after fast response for stop B is discarded', () async {
      await viewModel.doIntent(const DriverMapActivated());

      final aCompleter = Completer<ApiResult<DriverMapRouteEntity>>();
      repository.onGetRoute = (id) {
        if (id == 'stop-1') return aCompleter.future;
        return Future.value(
          ApiSuccessResult(
            data: DriverMapRouteEntity(
              tripId: 'trip-1',
              tripCode: 'TRP-1',
              focusedStop: repository.defaultRoute.stops[1],
              stops: repository.defaultRoute.stops,
              navigation: const DriverMapNavigationEntity(
                destinationStopId: 'stop-2',
                routeStatus: DriverMapRouteStatus.ready,
                canNavigate: true,
              ),
            ),
          ),
        );
      };

      // User selects stop-2, then immediately stop-1, then back to stop-2
      final futureA = viewModel.doIntent(const DriverMapStopSelected('stop-1'));
      final futureB = viewModel.doIntent(const DriverMapStopSelected('stop-2'));

      await futureB;
      expect(viewModel.state.selectedStopId, 'stop-2');
      expect(viewModel.state.visibleNavigation?.destinationStopId, 'stop-2');

      // Now old slow A finishes:
      aCompleter.complete(
        ApiSuccessResult(
          data: DriverMapRouteEntity(
            tripId: 'trip-1',
            tripCode: 'TRP-1',
            focusedStop: repository.defaultRoute.stops[0],
            stops: repository.defaultRoute.stops,
            navigation: const DriverMapNavigationEntity(
              destinationStopId: 'stop-1',
              routeStatus: DriverMapRouteStatus.ready,
              canNavigate: true,
            ),
          ),
        ),
      );
      await futureA;

      // State MUST remain stop-2, not overridden by slow A!
      expect(viewModel.state.selectedStopId, 'stop-2');
      expect(viewModel.state.visibleNavigation?.destinationStopId, 'stop-2');
    });

    test('404 DriverTrip.NotFound sets isEmpty = true and clears route/navigation', () async {
      repository.onGetRoute = (_) async => ApiErrorResult(
            failure: ServerFailure.fromResponse(
              Response(
                requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
                statusCode: 404,
                data: {
                  'title': 'Not found',
                  'extensions': {'code': 'DriverTrip.NotFound'},
                },
              ),
            ),
          );

      await viewModel.doIntent(const DriverMapActivated());

      expect(viewModel.state.isEmpty, isTrue);
      expect(viewModel.state.route, isNull);
      expect(viewModel.state.visibleNavigation, isNull);
      expect(viewModel.state.selectedStopId, isNull);
      expect(viewModel.state.failure, isNull); // Empty state, not red error
    });

    test('404 DriverMap.StopNotFound triggers fallback fetch with null focusedStopId', () async {
      int callCount = 0;
      repository.onGetRoute = (id) async {
        callCount++;
        if (id == 'deleted-stop') {
          return ApiErrorResult(
            failure: ServerFailure.fromResponse(
              Response(
                requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
                statusCode: 404,
                data: {
                  'title': 'Stop not found',
                  'extensions': {'code': 'DriverMap.StopNotFound'},
                },
              ),
            ),
          );
        }
        return ApiSuccessResult(data: repository.defaultRoute);
      };

      // Attempt with a specific deleted stop
      await viewModel.doIntent(const DriverMapActivated());
      await viewModel.doIntent(const DriverMapStopSelected('deleted-stop'));

      expect(callCount, 3); // initial + select deleted-stop + fallback without focus
      expect(repository.requestedStopIds.last, isNull);
      expect(viewModel.state.selectedStopId, 'stop-1');
    });

    test('GPS fixes update liveLocation without sending route GET requests', () async {
      await viewModel.doIntent(const DriverMapActivated());
      final initialGetCount = repository.requestedStopIds.length;

      final sample = DriverLiveLocationSample(
        latitude: 29.34,
        longitude: 48.03,
        recordedAtUtc: DateTime.now().toUtc(),
      );

      coordinator.emitSample(sample);
      await pumpEventQueue();

      expect(viewModel.state.liveLocation?.latitude, 29.34);
      expect(repository.requestedStopIds.length, initialGetCount); // No GET fired!
    });

    test('mismatch destinationStopId does not display visibleNavigation', () async {
      repository.onGetRoute = (_) async => ApiSuccessResult(
            data: DriverMapRouteEntity(
              tripId: 'trip-1',
              tripCode: 'TRP-1',
              focusedStop: repository.defaultRoute.stops[0],
              stops: repository.defaultRoute.stops,
              navigation: const DriverMapNavigationEntity(
                destinationStopId: 'different-stop', // Mismatch!
                routeStatus: DriverMapRouteStatus.ready,
                canNavigate: true,
              ),
            ),
          );

      await viewModel.doIntent(const DriverMapActivated());

      expect(viewModel.state.selectedStopId, 'stop-1');
      expect(viewModel.state.visibleNavigation, isNull); // Mismatch suppressed!
    });
  });
}
