import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_location_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_navigation_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/manager/driver_map_view_model.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/screens/driver_map_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/tracking/domain/entities/driver_live_location_sample.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';

class MockLiveLocationCoordinator implements DriverLiveLocationCoordinator {
  final _controller = StreamController<DriverLiveLocationSample>.broadcast();

  void close() => _controller.close();

  @override
  Stream<DriverLiveLocationSample> get positions => _controller.stream;

  @override
  DriverLiveLocationSample? latestLocation;

  @override
  DriverLiveLocationSample? lastSuccessfullySentLocation;

  @override
  Future<bool> sendCurrentLocationNow() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRouteUseCase implements GetDriverMapRouteUseCase {
  int callCount = 0;
  String? lastFocusedStopId;

  static const sampleStop = DriverMapStopEntity(
    id: 'stop-1',
    boxCode: 'BX-001',
    customerName: 'Customer',
    area: 'Area',
    formattedAddress: 'Address',
    mealsCount: 2,
    deliveryTimeSlot: '12:00 PM',
    status: DriverDeliveryStatus.inProgress,
    latitude: 29.3,
    longitude: 48.0,
  );

  static const sampleRoute = DriverMapRouteEntity(
    tripId: 'trip-1',
    tripCode: 'TRP-1',
    totalStopsCount: 1,
    completedStopsCount: 0,
    stops: [sampleStop],
    focusedStop: sampleStop,
    navigation: DriverMapNavigationEntity(
      routeStatus: DriverMapRouteStatus.ready,
      canNavigate: true,
      distanceMeters: 1000,
      durationSeconds: 120,
      destinationStopId: 'stop-1',
      origin: DriverMapLocationEntity(
        latitude: 29.3,
        longitude: 48.0,
        label: 'Driver',
        source: 'tracking',
      ),
      destination: DriverMapLocationEntity(
        latitude: 29.3,
        longitude: 48.0,
        label: 'Customer',
        source: 'trip_stop',
      ),
    ),
  );

  @override
  Future<ApiResult<DriverMapRouteEntity>> call({String? focusedStopId}) async {
    callCount++;
    lastFocusedStopId = focusedStopId;
    return const ApiSuccessResult(data: sampleRoute);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets(
      'isActive: false does not fetch route, toggling to true triggers activation',
      (tester) async {
    final useCase = MockRouteUseCase();
    final coordinator = MockLiveLocationCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      bootstrapWaitLimit: Duration.zero,
      pollingInterval: const Duration(seconds: 30),
    );

    // Mount with isActive = false
    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm, isActive: false)),
    );
    await tester.pump();

    expect(useCase.callCount, equals(0));
    expect(vm.state.isActive, isFalse);

    // Toggle to isActive = true
    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm, isActive: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(useCase.callCount, equals(1));
    expect(vm.state.isActive, isTrue);

    // Toggle back to isActive = false
    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm, isActive: false)),
    );
    await tester.pump();

    expect(vm.state.isActive, isFalse);

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });

  testWidgets(
      'lifecycle paused pauses polling, resumed while active triggers refresh',
      (tester) async {
    final useCase = MockRouteUseCase();
    final coordinator = MockLiveLocationCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      bootstrapWaitLimit: Duration.zero,
      pollingInterval: const Duration(seconds: 30),
    );

    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm, isActive: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(useCase.callCount, equals(1));

    // Simulate App entering background
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(vm.state.isForeground, isFalse);

    // Simulate App resuming while active
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(vm.state.isForeground, isTrue);
    expect(useCase.callCount, equals(2));

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });

  testWidgets('lifecycle resumed while inactive does NOT trigger refresh',
      (tester) async {
    final useCase = MockRouteUseCase();
    final coordinator = MockLiveLocationCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      bootstrapWaitLimit: Duration.zero,
      pollingInterval: const Duration(seconds: 30),
    );

    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm, isActive: false)),
    );
    await tester.pump();

    expect(useCase.callCount, equals(0));

    // Simulate paused then resumed while inactive
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(useCase.callCount, equals(0));

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });
}
