import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_active_box_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_current_location_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_daily_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/repo/driver_details_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/acquire_driver_details_realtime_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_active_boxes_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_current_location_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/get_driver_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/observe_driver_details_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/usecase/release_driver_details_realtime_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/screens/dispatcher_driver_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/services/driver_contact_launcher.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_boxes_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_boxes_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart';

class StubContactLauncher implements DriverContactLauncher {
  StubContactLauncher({this.shouldSucceed = true});

  final bool shouldSucceed;
  String? lastLaunchedPhone;
  String? lastLaunchedSms;
  String? lastLaunchedWhatsApp;

  @override
  Uri? phoneUri(String? phone) => phone != null ? Uri.parse('tel:$phone') : null;

  @override
  Uri? smsUri(String? phone) => phone != null ? Uri.parse('sms:$phone') : null;

  @override
  Uri? whatsAppUri(String? phone) => phone != null ? Uri.parse('https://wa.me/$phone') : null;

  @override
  Future<bool> launchPhone(String? phone) async {
    lastLaunchedPhone = phone;
    return shouldSucceed;
  }

  @override
  Future<bool> launchSms(String? phone) async {
    lastLaunchedSms = phone;
    return shouldSucceed;
  }

  @override
  Future<bool> launchWhatsApp(String? phone) async {
    lastLaunchedWhatsApp = phone;
    return shouldSucceed;
  }
}

class FakeDriverDetailsViewModel extends DriverDetailsViewModel {
  FakeDriverDetailsViewModel({
    required String driverId,
    DriverDetailsState initialState = const DriverDetailsState(),
  }) : super(
          driverId,
          _FakeGetDetailsUseCase(),
          _FakeGetActiveBoxesUseCase(),
          _FakeGetCurrentLocationUseCase(),
          _FakeObserveUpdatesUseCase(),
          _FakeAcquireRealtimeUseCase(),
          _FakeReleaseRealtimeUseCase(),
        ) {
    emit(initialState);
  }

  final List<DriverDetailsEvent> eventsDispatched = [];

  @override
  Future<void> doIntent(DriverDetailsEvent event) async {
    eventsDispatched.add(event);
  }

  void updateState(DriverDetailsState newState) {
    emit(newState);
  }
}

class _FakeGetDetailsUseCase extends GetDriverDetailsUseCase {
  _FakeGetDetailsUseCase() : super(_StubRepo());
}

class _FakeGetActiveBoxesUseCase extends GetDriverActiveBoxesUseCase {
  _FakeGetActiveBoxesUseCase() : super(_StubRepo());
}

class _FakeGetCurrentLocationUseCase extends GetDriverCurrentLocationUseCase {
  _FakeGetCurrentLocationUseCase() : super(_StubRepo());
}

class _FakeObserveUpdatesUseCase extends ObserveDriverDetailsUpdatesUseCase {
  _FakeObserveUpdatesUseCase() : super(_StubMapRepo());
}

class _FakeAcquireRealtimeUseCase extends AcquireDriverDetailsRealtimeUseCase {
  _FakeAcquireRealtimeUseCase() : super(_StubRealtimeClient());
}

class _FakeReleaseRealtimeUseCase extends ReleaseDriverDetailsRealtimeUseCase {
  _FakeReleaseRealtimeUseCase() : super(_StubRealtimeClient());
}

class _StubRepo implements DriverDetailsRepository {
  @override
  Future<ApiResult<DriverDetailsEntity>> getDetails(String driverId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<DriverActiveBoxEntity>>> getActiveBoxes(String driverId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<DriverCurrentLocationEntity>> getCurrentLocation(String driverId) =>
      throw UnimplementedError();
}

class _StubMapRepo implements DispatcherMapRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses => const Stream.empty();

  @override
  Stream<DispatcherMapRealtimeEvent> get realtimeEvents => const Stream.empty();
}

class _StubRealtimeClient implements DispatcherMapRealtimeClient {
  @override
  Future<void> acquire(String ownerId) async {}

  @override
  Future<void> release(String ownerId) async {}

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses => const Stream.empty();

  @override
  Stream<DispatcherMapRealtimeEventDto> get events => const Stream.empty();
}

Widget createTestScreen({
  required String driverId,
  required DriverDetailsViewModel viewModel,
  DriverContactLauncher? contactLauncher,
  VoidCallback? onOpenMap,
  ValueChanged<DriverActiveBoxEntity>? onSelectBox,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    locale: locale,
    home: DispatcherDriverDetailsScreen(
      driverId: driverId,
      viewModel: viewModel,
      contactLauncher: contactLauncher,
      onOpenMap: onOpenMap,
      onSelectBox: onSelectBox,
    ),
  );
}

void main() {
  const driverId = '8f3a3c21-9b12-42e7-90c1-872f2316e110';

  const testDetails = DriverDetailsEntity(
    driver: DriverProfileEntity(
      driverId: driverId,
      driverCode: 'DR-1025',
      fullName: 'Ahmed Al-Saeed',
      phoneNumber: '+96550123456',
      status: DriverDetailsStatus.available,
      statusText: 'Available',
      statusDotColor: '#10B981',
      lastUpdatedText: 'Just now',
    ),
    kpis: DriverKpisEntity(
      activeBoxesCount: 2,
      deliveredTodayCount: 15,
      avgDelayMinutes: 5,
      performanceRating: 4.8,
    ),
    dailySummary: DriverDailySummaryEntity(
      approxKm: 65,
      avgDelayMinutes: 5,
      failedDeliveryCount: 0,
      deliveredCount: 15,
    ),
  );

  const testLocation = DriverCurrentLocationEntity(
    latitude: 29.3375,
    longitude: 48.0211,
    statusBadgeText: 'Out for Delivery',
    timeAgoText: '5 min ago',
    streetName: 'Salem Al Mubarak St',
    areaName: 'Salmiya',
    routePoints: [],
  );

  const testBox = DriverActiveBoxEntity(
    boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
    boxCode: 'BX-2041',
    status: 'Delivering',
    statusText: 'Delivering',
    statusColor: '#6366F1',
    customerName: 'Fatima Al-Zahra',
    scheduledTimeText: '1:30 PM',
    deliveryAddress: 'Block 4, Street 10',
  );

  group('DispatcherDriverDetailsScreen State Rendering', () {
    testWidgets('renders full DriverDetailsShimmer on initial profile loading', (
      tester,
    ) async {
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: const DriverDetailsState(
          isProfileLoading: true,
          details: null,
        ),
      );

      await tester.pumpWidget(createTestScreen(driverId: driverId, viewModel: vm));

      expect(find.byType(DriverDetailsShimmer), findsOneWidget);
      expect(find.text('Ahmed Al-Saeed'), findsNothing);
    });

    testWidgets('renders ApiErrorWidget on initial profile failure', (tester) async {
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: DriverDetailsState(
          isProfileLoading: false,
          details: null,
          profileFailure: ServerFailure(
            errorMessage: 'Server unavailable',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server error',
            ),
          ),
        ),
      );

      await tester.pumpWidget(createTestScreen(driverId: driverId, viewModel: vm));

      expect(find.byType(ApiErrorWidget), findsOneWidget);
    });

    testWidgets('renders independent section shimmers and inline errors', (tester) async {
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: DriverDetailsState(
          details: testDetails,
          isLocationLoading: true,
          location: null,
          boxesFailure: ServerFailure(
            errorMessage: 'Boxes failed',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Boxes error',
            ),
          ),
          activeBoxes: null,
        ),
      );

      await tester.pumpWidget(createTestScreen(driverId: driverId, viewModel: vm));

      expect(find.text('Ahmed Al-Saeed'), findsOneWidget);
      expect(find.byType(DriverDetailsLocationShimmer), findsOneWidget);
      expect(find.byType(InlineApiErrorWidget), findsOneWidget);
    });

    testWidgets('renders complete success state with all cards', (tester) async {
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: const DriverDetailsState(
          details: testDetails,
          location: testLocation,
          activeBoxes: [testBox],
        ),
      );

      await tester.pumpWidget(createTestScreen(driverId: driverId, viewModel: vm));

      expect(find.text('Ahmed Al-Saeed'), findsOneWidget);
      expect(find.text('DR-1025'), findsOneWidget);
      expect(find.byType(DriverDetailsLocationCard), findsOneWidget);
      expect(find.byType(DriverDetailsBoxesCard), findsOneWidget);
      expect(find.text('BX-2041'), findsOneWidget);
    });

    testWidgets('triggers onSelectBox when an active box is tapped', (tester) async {
      DriverActiveBoxEntity? tappedBox;
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: const DriverDetailsState(
          details: testDetails,
          location: testLocation,
          activeBoxes: [testBox],
        ),
      );

      await tester.pumpWidget(
        createTestScreen(
          driverId: driverId,
          viewModel: vm,
          onSelectBox: (box) => tappedBox = box,
        ),
      );

      await tester.tap(find.text('BX-2041'));
      expect(tappedBox, isNotNull);
      expect(tappedBox!.boxId, testBox.boxId);
    });

    testWidgets('triggers onOpenMap when Open on Map is tapped', (tester) async {
      var mapTapped = false;
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: const DriverDetailsState(
          details: testDetails,
          location: testLocation,
          activeBoxes: [testBox],
        ),
      );

      await tester.pumpWidget(
        createTestScreen(
          driverId: driverId,
          viewModel: vm,
          onOpenMap: () => mapTapped = true,
        ),
      );

      await tester.tap(find.text('Open on Map'));
      expect(mapTapped, isTrue);
    });

    testWidgets('launches contact calls when Call button is tapped', (tester) async {
      final launcher = StubContactLauncher(shouldSucceed: true);
      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: const DriverDetailsState(
          details: testDetails,
          location: testLocation,
          activeBoxes: [testBox],
        ),
      );

      await tester.pumpWidget(
        createTestScreen(
          driverId: driverId,
          viewModel: vm,
          contactLauncher: launcher,
        ),
      );

      await tester.ensureVisible(find.text('Call'));
      await tester.tap(find.text('Call'));
      await tester.pump();
      expect(launcher.lastLaunchedPhone, '+96550123456');
    });

    testWidgets('does not overflow on 320x640 small screen viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vm = FakeDriverDetailsViewModel(
        driverId: driverId,
        initialState: const DriverDetailsState(
          details: testDetails,
          location: testLocation,
          activeBoxes: [testBox],
        ),
      );

      await tester.pumpWidget(createTestScreen(driverId: driverId, viewModel: vm));

      expect(tester.takeException(), isNull);
    });
  });
}
