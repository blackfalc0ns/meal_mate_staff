import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_location_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_navigation_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/manager/driver_map_view_model.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/screens/driver_map_screen.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_active_order_card.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_navigation_panel.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_shimmer.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_stops_carousel.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/tracking/domain/entities/driver_live_location_sample.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';

class FakeCoordinator implements DriverLiveLocationCoordinator {
  final _positionsController =
      StreamController<DriverLiveLocationSample>.broadcast();

  void close() => _positionsController.close();

  @override
  Stream<DriverLiveLocationSample> get positions => _positionsController.stream;

  @override
  DriverLiveLocationSample? latestLocation;

  @override
  DriverLiveLocationSample? lastSuccessfullySentLocation;

  @override
  Future<bool> sendCurrentLocationNow() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetDriverMapRouteUseCase implements GetDriverMapRouteUseCase {
  FakeGetDriverMapRouteUseCase(this.handler);

  final Future<ApiResult<DriverMapRouteEntity>> Function(String? focusedStopId)
      handler;

  @override
  Future<ApiResult<DriverMapRouteEntity>> call({String? focusedStopId}) =>
      handler(focusedStopId);

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

  testWidgets('renders DriverMapShimmer when initial loading', (tester) async {
    final completer = Completer<ApiResult<DriverMapRouteEntity>>();
    final useCase = FakeGetDriverMapRouteUseCase((_) => completer.future);
    final coordinator = FakeCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
    );

    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm, isActive: false)),
    );
    expect(find.byType(DriverMapShimmer), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });

  testWidgets('renders ApiErrorWidget when failure and no route',
      (tester) async {
    final useCase = FakeGetDriverMapRouteUseCase((_) async {
      return ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Server error',
          exception: const ApiException(
            errorType: ApiErrorType.serverError,
            statusCode: 500,
            message: 'Internal Error',
          ),
        ),
      );
    });
    final coordinator = FakeCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      bootstrapWaitLimit: Duration.zero,
    );

    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm)),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ApiErrorWidget), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });

  testWidgets('renders EmptyStateWidget when isEmpty is true', (tester) async {
    final useCase = FakeGetDriverMapRouteUseCase((_) async {
      return ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Trip not found',
          code: 'DriverTrip.NotFound',
          exception: const ApiException(
            errorType: ApiErrorType.notFound,
            statusCode: 404,
            backendErrorCode: 'DriverTrip.NotFound',
            message: 'Trip not found',
          ),
        ),
      );
    });
    final coordinator = FakeCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      bootstrapWaitLimit: Duration.zero,
    );

    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm)),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(EmptyStateWidget), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });

  testWidgets('renders full content when route succeeds', (tester) async {
    const stop1 = DriverMapStopEntity(
      id: 'stop-1',
      boxCode: '#BX-1',
      customerName: 'Customer One',
      area: 'Salmiya',
      formattedAddress: 'Gulf Road',
      mealsCount: 2,
      deliveryTimeSlot: '10:00 AM',
      status: DriverDeliveryStatus.inProgress,
      isCurrent: true,
      latitude: 29.33,
      longitude: 48.02,
    );
    const route = DriverMapRouteEntity(
      tripId: 'trip-1',
      tripCode: 'TRP-1',
      totalStopsCount: 1,
      completedStopsCount: 0,
      stops: [stop1],
      focusedStop: stop1,
      navigation: DriverMapNavigationEntity(
        routeStatus: DriverMapRouteStatus.ready,
        canNavigate: true,
        distanceMeters: 3000,
        durationSeconds: 300,
        destinationStopId: 'stop-1',
        origin: DriverMapLocationEntity(
          latitude: 29.3,
          longitude: 48.0,
          label: 'Origin',
          source: 'tracking',
        ),
        destination: DriverMapLocationEntity(
          latitude: 29.33,
          longitude: 48.02,
          label: 'Dest',
          source: 'trip_stop',
        ),
      ),
    );

    final useCase = FakeGetDriverMapRouteUseCase(
      (_) async => const ApiSuccessResult(data: route),
    );
    final coordinator = FakeCoordinator();
    final vm = DriverMapViewModel(
      getDriverMapRouteUseCase: useCase,
      liveLocationCoordinator: coordinator,
      bootstrapWaitLimit: Duration.zero,
    );

    await tester.pumpWidget(
      buildApp(DriverMapScreen(viewModel: vm)),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
    expect(find.byType(DriverMapNavigationPanel), findsOneWidget);
    expect(find.byType(DriverMapStopsCarousel), findsOneWidget);
    expect(find.text('Customer One'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await vm.close();
    coordinator.close();
  });
}
