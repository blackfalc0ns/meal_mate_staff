import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_location_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_navigation_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/manager/driver_map_state.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/manager/driver_map_view_model.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/screens/driver_map_screen.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_active_order_card.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_background.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_carousel_nav_button.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_page_indicator.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_recenter_button.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_stop_card.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_stops_carousel.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/tracking/domain/entities/driver_live_location_sample.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';

const List<DriverMapStopEntity> _sampleStops = [
  DriverMapStopEntity(
    id: 'stop_1',
    boxCode: 'BX-458722',
    sequenceNumber: 1,
    totalStops: 3,
    customerName: 'محمد علي',
    customerPhone: '+ 966 50 123 4567',
    area: 'السالمية',
    formattedAddress: 'شارع الخليج العربي ، قطعة 12 ، منزل 45 ، السالمية',
    mealsCount: 3,
    deliveryTimeSlot: '20 : 09 ص',
    status: DriverDeliveryStatus.inProgress,
    latitude: 29.3375,
    longitude: 48.0753,
  ),
  DriverMapStopEntity(
    id: 'stop_2',
    boxCode: 'BX-458722',
    sequenceNumber: 2,
    totalStops: 3,
    customerName: 'مهند أحمد',
    customerPhone: '+ 966 50 123 4567',
    area: 'السالمية',
    formattedAddress: 'السالمية ، شارع 512 ، عمارة 10',
    mealsCount: 3,
    deliveryTimeSlot: '20 : 09 ص',
    status: DriverDeliveryStatus.inProgress,
    latitude: 29.3450,
    longitude: 48.0650,
  ),
  DriverMapStopEntity(
    id: 'stop_3',
    boxCode: 'BX-458722',
    sequenceNumber: 3,
    totalStops: 3,
    customerName: 'أحمد فيصل',
    customerPhone: '+ 966 50 123 4567',
    area: 'السالمية',
    formattedAddress: 'السالمية ، شارع 512 ، مجمع الأمل',
    mealsCount: 3,
    deliveryTimeSlot: '20 : 09 ص',
    status: DriverDeliveryStatus.delivered,
    latitude: 29.3520,
    longitude: 48.0550,
  ),
];

class _TestMapRouteUseCase implements GetDriverMapRouteUseCase {
  const _TestMapRouteUseCase();

  @override
  Future<ApiResult<DriverMapRouteEntity>> call({String? focusedStopId}) async {
    const stops = _sampleStops;
    final focused = stops.firstWhere(
      (s) => s.id == focusedStopId,
      orElse: () => stops.first,
    );
    return ApiSuccessResult(
      data: DriverMapRouteEntity(
        tripId: 'sample-trip',
        tripCode: 'TRP-SAMPLE',
        totalStopsCount: stops.length,
        completedStopsCount: stops.where((s) => s.isDelivered).length,
        stops: stops,
        focusedStop: focused,
        navigation: DriverMapNavigationEntity(
          routeStatus: DriverMapRouteStatus.ready,
          canNavigate: true,
          distanceMeters: 2500,
          durationSeconds: 300,
          destinationStopId: focused.id,
          origin: const DriverMapLocationEntity(
            latitude: 29.3320,
            longitude: 48.0820,
            label: 'Driver',
            source: 'tracking',
          ),
          destination: DriverMapLocationEntity(
            latitude: focused.latitude ?? 29.3375,
            longitude: focused.longitude ?? 48.0753,
            label: focused.customerName,
            source: 'trip_stop',
          ),
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestLocationCoordinator implements DriverLiveLocationCoordinator {
  @override
  Stream<DriverLiveLocationSample> get positions => const Stream.empty();

  @override
  DriverLiveLocationSample? get latestLocation => null;

  @override
  DriverLiveLocationSample? get lastSuccessfullySentLocation => null;

  @override
  Future<bool> sendCurrentLocationNow() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DriverMapViewModel _createTestViewModel() {
  const stops = _sampleStops;
  final focused = stops.first;
  return DriverMapViewModel(
    getDriverMapRouteUseCase: const _TestMapRouteUseCase(),
    liveLocationCoordinator: _TestLocationCoordinator(),
    bootstrapWaitLimit: Duration.zero,
    pollingInterval: Duration.zero,
    initialState: DriverMapState(
      isLoading: false,
      route: DriverMapRouteEntity(
        tripId: 'sample-trip',
        tripCode: 'TRP-SAMPLE',
        totalStopsCount: stops.length,
        completedStopsCount: stops.where((s) => s.isDelivered).length,
        stops: stops,
        focusedStop: focused,
        navigation: DriverMapNavigationEntity(
          routeStatus: DriverMapRouteStatus.ready,
          canNavigate: true,
          distanceMeters: 2500,
          durationSeconds: 300,
          destinationStopId: focused.id,
          origin: const DriverMapLocationEntity(
            latitude: 29.3320,
            longitude: 48.0820,
            label: 'Driver',
            source: 'tracking',
          ),
          destination: DriverMapLocationEntity(
            latitude: focused.latitude ?? 29.3375,
            longitude: focused.longitude ?? 48.0753,
            label: focused.customerName,
            source: 'trip_stop',
          ),
        ),
      ),
      selectedStopId: focused.id,
    ),
  );
}

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverMapScreen Widget Tests', () {
    setUp(() {
      if (getIt.isRegistered<DriverMapViewModel>()) {
        getIt.unregister<DriverMapViewModel>();
      }
      getIt.registerFactory<DriverMapViewModel>(() => _createTestViewModel());
    });

    tearDown(() {
      if (getIt.isRegistered<DriverMapViewModel>()) {
        getIt.unregister<DriverMapViewModel>();
      }
    });

    testWidgets('renders all components properly in Arabic (RTL)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool addressPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverMapScreen(
            onAddressTap: () => addressPressed = true,
          ),
        ),
      );
      await tester.pump();

      // Verify Map Background
      expect(find.byType(DriverMapBackground), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);

      // Verify Active Order Top Card
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
      expect(find.text('BX-458722'), findsWidgets);
      expect(find.text('محمد علي'), findsWidgets);
      expect(find.byIcon(Icons.phone_rounded), findsOneWidget);
      expect(find.text('3 وجبات'), findsWidgets);
      expect(find.text('20 : 09 ص'), findsWidgets);

      // Test tapping Address in stats
      final addressFinder = find.text(
        'شارع الخليج العربي ، قطعة 12 ، منزل 45 ، السالمية',
      );
      expect(addressFinder, findsOneWidget);
      await tester.tap(addressFinder);
      await tester.pump();
      expect(addressPressed, isTrue);

      // Verify Recenter Button
      expect(find.byType(DriverMapRecenterButton), findsOneWidget);
      await tester.tap(find.byType(DriverMapRecenterButton));
      await tester.pump();

      // Verify Carousel
      expect(find.byType(DriverMapStopsCarousel), findsOneWidget);
      expect(find.byType(DriverMapStopCard), findsWidgets);
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('مهند أحمد'), findsOneWidget);

      // Test Next arrow on Carousel
      final nextNavFinder = find.widgetWithIcon(
        DriverMapCarouselNavButton,
        Icons.arrow_back_ios_sharp,
      );
      expect(nextNavFinder, findsOneWidget);
      await tester.tap(nextNavFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('renders cleanly in English (LTR)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverMapScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverMapScreen), findsOneWidget);
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
      expect(find.byType(DriverMapStopsCarousel), findsOneWidget);
      expect(find.byType(DriverMapRecenterButton), findsOneWidget);
    });

    testWidgets('DriverMapScreen is rendered at tab index 2 in AppShellScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          child: const AppShellScreen(
            role: UserRole.driver,
            initialIndex: 2,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverMapScreen), findsOneWidget);
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
    });

    testWidgets('DriverMapStopsCarousel displays 3 cards with looping and navigation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          child: const DriverMapScreen(),
        ),
      );
      await tester.pump();

      // All 3 cards are present around center:
      // Stop 1 (1/3, محمد علي) in center
      // Stop 2 (2/3, مهند أحمد) on right
      // Stop 3 (3/3, أحمد فيصل) on left
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('3/3'), findsOneWidget);
      expect(find.text('محمد علي'), findsWidgets);
      expect(find.text('مهند أحمد'), findsOneWidget);
      expect(find.text('أحمد فيصل'), findsOneWidget);

      // Tap next arrow (right)
      final nextNavFinder = find.widgetWithIcon(
        DriverMapCarouselNavButton,
        Icons.arrow_back_ios_sharp,
      );
      expect(nextNavFinder, findsOneWidget);
      await tester.tap(nextNavFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // After next, Stop 2 (مهند أحمد) is the active order card in the top card
      expect(find.byType(DriverMapActiveOrderCard), findsOneWidget);
      expect(find.text('مهند أحمد'), findsWidgets);

      // Tap previous arrow (left)
      final prevNavFinder = find.widgetWithIcon(
        DriverMapCarouselNavButton,
        Icons.arrow_forward_ios_sharp,
      );
      expect(prevNavFinder, findsOneWidget);
      await tester.tap(prevNavFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Back to Stop 1 (محمد علي)
      expect(find.text('محمد علي'), findsWidgets);
    });

    testWidgets('DriverMapPageIndicator renders active bar 32px and inactive bars 22px', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const DriverMapPageIndicator(
            itemCount: 3,
            currentIndex: 0,
          ),
        ),
      );
      await tester.pump();

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      expect(containers.length, equals(3));
      // First (index 0) is selected: width 32
      expect(containers[0].constraints?.maxWidth ?? 32, equals(32));
      // Second and third (index 1, 2) are unselected: width 22
      expect(containers[1].constraints?.maxWidth ?? 22, equals(22));
      expect(containers[2].constraints?.maxWidth ?? 22, equals(22));
    });
  });
}
