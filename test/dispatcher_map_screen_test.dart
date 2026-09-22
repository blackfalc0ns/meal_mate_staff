import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_connection_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/start_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/stop_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_camera_controller.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_controls.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_drivers_carousel.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_kpi_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_reconnect_banner.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_shimmer.dart';

class _FakeRepository implements DispatcherMapRepository {
  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses => const Stream.empty();

  @override
  Stream<DispatcherMapRealtimeEvent> get realtimeEvents => const Stream.empty();

  @override
  DispatcherMapConnectionStatus get currentConnectionStatus =>
      DispatcherMapConnectionStatus.disconnected;

  @override
  Future<void> startRealtimeUpdates() async {}

  @override
  Future<void> stopRealtimeUpdates() async {}

  @override
  Future<void> disposeRealtime() async {}

  @override
  Future<ApiResult<DispatcherLiveMonitoringEntity>> getLiveMonitoring({
    String? restaurantId,
    String? status,
  }) async {
    throw UnimplementedError();
  }
}

class FakeDispatcherMapCameraController implements DispatcherMapCameraController {
  int zoomInCount = 0;
  int zoomOutCount = 0;
  LatLng? lastCentered;
  List<DispatcherMapDriverEntity>? lastFittedDrivers;

  @override
  Future<void> zoomIn() async => zoomInCount++;

  @override
  Future<void> zoomOut() async => zoomOutCount++;

  @override
  Future<void> centerOn(LatLng coordinate, {double zoom = 15.0}) async {
    lastCentered = coordinate;
  }

  @override
  Future<void> fitDrivers(List<DispatcherMapDriverEntity> drivers, {double padding = 60}) async {
    lastFittedDrivers = drivers;
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {}
}

class FakeDispatcherMapViewModel extends DispatcherMapViewModel {
  FakeDispatcherMapViewModel({DispatcherMapState? initialState})
      : super(
          getLiveMonitoringUseCase: GetDispatcherLiveMonitoringUseCase(_FakeRepository()),
          observeUpdatesUseCase: ObserveDispatcherMapUpdatesUseCase(_FakeRepository()),
          observeConnectionStatusUseCase:
              ObserveDispatcherMapConnectionStatusUseCase(_FakeRepository()),
          startUpdatesUseCase: StartDispatcherMapUpdatesUseCase(_FakeRepository()),
          stopUpdatesUseCase: StopDispatcherMapUpdatesUseCase(_FakeRepository()),
        ) {
    if (initialState != null) {
      emit(initialState);
    }
  }

  final List<DispatcherMapEvent> recordedEvents = [];

  void setState(DispatcherMapState newState) {
    emit(newState);
  }

  @override
  Future<void> doIntent(DispatcherMapEvent event) async {
    recordedEvents.add(event);
  }
}

void main() {
  const testKpi = DispatcherMapKpiEntity(
    activeDriversCount: 32,
    inDeliveryCount: 18,
    pausedCount: 7,
    issuesCount: 3,
  );

  final List<DispatcherMapDriverEntity> testDrivers = [
    const DispatcherMapDriverEntity(
      id: 'd1',
      name: 'Ali Ahmed',
      boxId: 'BOX-101',
      status: DispatcherMapDriverStatus.inDelivery,
      latitude: 24.7136,
      longitude: 46.6753,
      locationZone: 'North District',
      remainingDistanceKm: 3.5,
    ),
    const DispatcherMapDriverEntity(
      id: 'd2',
      name: 'Omar Khaled',
      boxId: 'BOX-102',
      status: DispatcherMapDriverStatus.hasIssue,
      hasIssue: true,
      latitude: 24.7200,
      longitude: 46.6800,
      locationZone: 'East District',
      remainingDistanceKm: 1.2,
    ),
  ];

  final testMonitoring = DispatcherLiveMonitoringEntity(
    kpi: testKpi,
    drivers: testDrivers,
  );

  Widget buildSubject({
    required FakeDispatcherMapViewModel viewModel,
    required FakeDispatcherMapCameraController cameraController,
    Locale locale = const Locale('ar'),
    VoidCallback? onBack,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherMapScreen(
        onBack: onBack,
        viewModel: viewModel,
        cameraController: cameraController,
      ),
    );
  }

  group('DispatcherMapScreen Widget Tests', () {
    testWidgets('shows DispatcherMapShimmer during initial loading', (tester) async {
      final vm = FakeDispatcherMapViewModel(
        initialState: const DispatcherMapState(snapshot: null, failure: null),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pump();

      expect(find.byType(DispatcherMapShimmer), findsOneWidget);
      expect(find.byType(ApiErrorWidget), findsNothing);
      expect(find.byType(DispatcherMapDriversCarousel), findsNothing);
    });

    testWidgets('shows ApiErrorWidget on initial error and retries on tap', (tester) async {
      final failure = Failure.fromException(
        ApiException(
          errorType: ApiErrorType.noInternetConnection,
          message: 'No internet',
        ),
      );
      final vm = FakeDispatcherMapViewModel(
        initialState: DispatcherMapState(snapshot: null, failure: failure),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pumpAndSettle();

      expect(find.byType(ApiErrorWidget), findsOneWidget);
      expect(find.byType(DispatcherMapShimmer), findsNothing);

      final retryBtn = find.text('Retry');
      expect(retryBtn, findsOneWidget);

      await tester.tap(retryBtn);
      await tester.pump();

      expect(vm.recordedEvents.whereType<RetryDispatcherMapEvent>(), isNotEmpty);
    });

    testWidgets('renders populated state with KPI, carousel, and controls in Arabic', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = FakeDispatcherMapViewModel(
        initialState: DispatcherMapState(
          snapshot: testMonitoring,
          selectedDriverId: 'd1',
          connectionStatus: DispatcherMapConnectionStatus.connected,
        ),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pumpAndSettle();

      // Header
      expect(find.byType(DispatcherMapHeader), findsOneWidget);
      expect(find.text('متابعة السائقين'), findsOneWidget);

      // KPI Bar & Cards
      expect(find.byType(DispatcherMapKpiBar), findsOneWidget);
      expect(find.text('32'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Controls
      expect(find.byType(DispatcherMapControls), findsOneWidget);
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      // Carousel & Cards
      expect(find.byType(DispatcherMapDriversCarousel), findsOneWidget);
      expect(find.byType(DispatcherMapDriverCard), findsNWidgets(2));
      expect(find.text('Ali Ahmed'), findsOneWidget);
      expect(find.text('Omar Khaled'), findsOneWidget);
    });

    testWidgets('renders properly in English locale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = FakeDispatcherMapViewModel(
        initialState: DispatcherMapState(
          snapshot: testMonitoring,
          selectedDriverId: 'd1',
          connectionStatus: DispatcherMapConnectionStatus.connected,
        ),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(
        buildSubject(viewModel: vm, cameraController: cam, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Driver Tracking'), findsOneWidget);
      expect(find.text('Real-time driver monitoring'), findsOneWidget);
      expect(find.text('Active Driver'), findsOneWidget);
      expect(find.text('In Delivery'), findsWidgets);
    });

    testWidgets('shows EmptyStateWidget when drivers list is empty', (tester) async {
      const emptyMonitoring = DispatcherLiveMonitoringEntity(
        kpi: testKpi,
        drivers: [],
      );
      final vm = FakeDispatcherMapViewModel(
        initialState: const DispatcherMapState(
          snapshot: emptyMonitoring,
          connectionStatus: DispatcherMapConnectionStatus.connected,
        ),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.byType(DispatcherMapDriversCarousel), findsNothing);
    });

    testWidgets('shows ReconnectBanner when connection status is reconnecting', (tester) async {
      final vm = FakeDispatcherMapViewModel(
        initialState: DispatcherMapState(
          snapshot: testMonitoring,
          connectionStatus: DispatcherMapConnectionStatus.reconnecting,
        ),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DispatcherMapReconnectBanner), findsOneWidget);
      expect(find.text('جارٍ إعادة الاتصال بالبث المباشر...'), findsOneWidget);
    });

    testWidgets('tapping driver card selects driver and centers map camera', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = FakeDispatcherMapViewModel(
        initialState: DispatcherMapState(
          snapshot: testMonitoring,
          selectedDriverId: 'd1',
          connectionStatus: DispatcherMapConnectionStatus.connected,
        ),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pumpAndSettle();

      // Tap second driver card (Omar Khaled, d2)
      final secondCard = find.text('Omar Khaled');
      expect(secondCard, findsOneWidget);

      await tester.tap(secondCard);
      await tester.pump();

      expect(
        vm.recordedEvents.whereType<SelectDriverDispatcherMapEvent>().any((e) => e.driverId == 'd2'),
        isTrue,
      );
      expect(cam.lastCentered?.latitude, equals(24.7200));
      expect(cam.lastCentered?.longitude, equals(46.6800));
    });

    testWidgets('controls zoom and recenter trigger camera controller methods', (tester) async {
      final vm = FakeDispatcherMapViewModel(
        initialState: DispatcherMapState(
          snapshot: testMonitoring,
          selectedDriverId: 'd1',
          connectionStatus: DispatcherMapConnectionStatus.connected,
        ),
      );
      final cam = FakeDispatcherMapCameraController();

      await tester.pumpWidget(buildSubject(viewModel: vm, cameraController: cam));
      await tester.pumpAndSettle();

      // Zoom in
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(cam.zoomInCount, equals(1));

      // Zoom out
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(cam.zoomOutCount, equals(1));

      // Recenter
      await tester.tap(find.byIcon(Icons.my_location_rounded));
      await tester.pump();
      expect(cam.lastCentered?.latitude, equals(24.7136));
      expect(cam.lastCentered?.longitude, equals(46.6753));
    });
  });
}
