import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
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
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/manager/driver_details_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart';

class FakeRealtimeClient implements DispatcherMapRealtimeClient {
  final List<String> acquiredOwners = [];
  final List<String> releasedOwners = [];

  @override
  Future<void> acquire(String ownerId) async {
    acquiredOwners.add(ownerId);
  }

  @override
  Future<void> release(String ownerId) async {
    releasedOwners.add(ownerId);
  }

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      const Stream.empty();

  @override
  Stream<DispatcherMapRealtimeEventDto> get events => const Stream.empty();
}

class FakeMapRepository implements DispatcherMapRepository {
  final eventController =
      StreamController<DispatcherMapRealtimeEvent>.broadcast();
  final statusController =
      StreamController<DispatcherMapConnectionStatus>.broadcast();

  @override
  Stream<DispatcherMapRealtimeEvent> get realtimeEvents =>
      eventController.stream;

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      statusController.stream;

  @override
  DispatcherMapConnectionStatus get currentConnectionStatus =>
      DispatcherMapConnectionStatus.connected;

  @override
  Future<void> disposeRealtime() async {}

  @override
  Future<ApiResult<DispatcherLiveMonitoringEntity>> getLiveMonitoring(
      {String? restaurantId, String? status}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> startRealtimeUpdates() async {}

  @override
  Future<void> stopRealtimeUpdates() async {}
}

class FakeDetailsRepo implements DriverDetailsRepository {
  DriverDetailsEntity? detailsData;
  List<DriverActiveBoxEntity>? boxesData;
  DriverCurrentLocationEntity? locationData;

  Failure? detailsError;
  Failure? boxesError;
  Failure? locationError;

  int detailsCalls = 0;
  int boxesCalls = 0;
  int locationCalls = 0;

  Completer<void>? delayCompleter;

  @override
  Future<ApiResult<DriverDetailsEntity>> getDetails(String driverId) async {
    detailsCalls++;
    if (delayCompleter != null) await delayCompleter!.future;
    if (detailsError != null) {
      return ApiErrorResult(failure: detailsError!);
    }
    return ApiSuccessResult(data: detailsData ?? _defaultDetails(driverId));
  }

  @override
  Future<ApiResult<List<DriverActiveBoxEntity>>> getActiveBoxes(
      String driverId) async {
    boxesCalls++;
    if (delayCompleter != null) await delayCompleter!.future;
    if (boxesError != null) {
      return ApiErrorResult(failure: boxesError!);
    }
    return ApiSuccessResult(data: boxesData ?? []);
  }

  @override
  Future<ApiResult<DriverCurrentLocationEntity>> getCurrentLocation(
      String driverId) async {
    locationCalls++;
    if (delayCompleter != null) await delayCompleter!.future;
    if (locationError != null) {
      return ApiErrorResult(failure: locationError!);
    }
    return ApiSuccessResult(data: locationData ?? _defaultLocation());
  }

  static DriverDetailsEntity _defaultDetails(String id) => DriverDetailsEntity(
        driver: DriverProfileEntity(
          driverId: id,
          driverCode: 'DR-1025',
          fullName: 'أحمد السعيد',
          phoneNumber: '+965501234567',
          status: DriverDetailsStatus.available,
          statusText: 'متاح',
          lastUpdatedText: 'الآن',
        ),
        kpis: const DriverKpisEntity(
          performanceRating: 4.8,
          avgDelayMinutes: 12,
          deliveredTodayCount: 28,
          activeBoxesCount: 2,
        ),
        dailySummary: const DriverDailySummaryEntity(
          approxKm: 120,
          avgDelayMinutes: 12,
          failedDeliveryCount: 1,
          deliveredCount: 28,
        ),
      );

  static DriverCurrentLocationEntity _defaultLocation() =>
      const DriverCurrentLocationEntity(
        latitude: 29.3375,
        longitude: 47.9784,
        statusBadgeText: 'مباشر',
        timeAgoText: 'الآن',
        streetName: 'شارع الملك فهد',
        areaName: 'حي العليا',
      );
}

void main() {
  const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';
  const otherDriverId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

  late FakeDetailsRepo repo;
  late FakeMapRepository mapRepo;
  late FakeRealtimeClient realtimeClient;
  late DriverDetailsViewModel viewModel;

  setUp(() {
    repo = FakeDetailsRepo();
    mapRepo = FakeMapRepository();
    realtimeClient = FakeRealtimeClient();

    viewModel = DriverDetailsViewModel(
      driverId,
      GetDriverDetailsUseCase(repo),
      GetDriverActiveBoxesUseCase(repo),
      GetDriverCurrentLocationUseCase(repo),
      ObserveDriverDetailsUpdatesUseCase(mapRepo),
      AcquireDriverDetailsRealtimeUseCase(realtimeClient),
      ReleaseDriverDetailsRealtimeUseCase(realtimeClient),
    );
  });

  tearDown(() async {
    await viewModel.close();
    await mapRepo.eventController.close();
    await mapRepo.statusController.close();
  });

  group('DriverDetailsViewModel State Machine', () {
    test('concurrent initial loads populates all sections independently',
        () async {
      expect(viewModel.state.isProfileLoading, isFalse);

      final loadFuture = viewModel.doIntent(const LoadDriverDetailsEvent());
      expect(viewModel.state.isProfileLoading, isTrue);
      expect(viewModel.state.isBoxesLoading, isTrue);
      expect(viewModel.state.isLocationLoading, isTrue);

      await loadFuture;

      expect(viewModel.state.isProfileLoading, isFalse);
      expect(viewModel.state.isBoxesLoading, isFalse);
      expect(viewModel.state.isLocationLoading, isFalse);
      expect(viewModel.state.details, isNotNull);
      expect(viewModel.state.activeBoxes, isNotNull);
      expect(viewModel.state.location, isNotNull);
      expect(realtimeClient.acquiredOwners, contains('driver-details:$driverId'));
    });

    test('profile initial failure keeps error in state without clearing partial successes',
        () async {
      repo.detailsError = ServerFailure(
        errorMessage: 'Profile load failed',
        exception: const ApiException(
          errorType: ApiErrorType.serverError,
          message: 'Profile load failed',
        ),
      );

      await viewModel.doIntent(const LoadDriverDetailsEvent());

      expect(viewModel.state.details, isNull);
      expect(viewModel.state.profileFailure, isNotNull);
      expect(viewModel.state.profileFailure?.errorMessage, 'Profile load failed');
      // Boxes and location succeeded
      expect(viewModel.state.activeBoxes, isNotNull);
      expect(viewModel.state.location, isNotNull);
      expect(viewModel.state.boxesFailure, isNull);
    });

    test('boxes failure produces inline error state while profile remains visible',
        () async {
      repo.boxesError = ServerFailure(
        errorMessage: 'Boxes load failed',
        exception: const ApiException(
          errorType: ApiErrorType.serverError,
          message: 'Boxes load failed',
        ),
      );

      await viewModel.doIntent(const LoadDriverDetailsEvent());

      expect(viewModel.state.details, isNotNull);
      expect(viewModel.state.activeBoxes, isNull);
      expect(viewModel.state.boxesFailure, isNotNull);
      expect(viewModel.state.boxesFailure?.errorMessage, 'Boxes load failed');
    });

    test('pull-to-refresh preserves existing data and notifies error via noticeId',
        () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      expect(viewModel.state.details, isNotNull);

      // Now simulate boxes error on refresh
      repo.boxesError = ServerFailure(
        errorMessage: 'Network glitch on refresh',
        exception: const ApiException(
          errorType: ApiErrorType.serverError,
          message: 'Network glitch on refresh',
        ),
      );

      await viewModel.doIntent(const RefreshDriverDetailsEvent());

      // Data is preserved!
      expect(viewModel.state.details, isNotNull);
      expect(viewModel.state.activeBoxes, isNotNull);
      // Non-fatal notice emitted
      expect(viewModel.state.noticeFailure, isNotNull);
      expect(viewModel.state.noticeFailure?.errorMessage,
          'Network glitch on refresh');
      expect(viewModel.state.noticeId, 1);
    });

    test('ignores realtime location events for other drivers', () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      final initialLocation = viewModel.state.location;

      await viewModel.doIntent(
        RealtimeDriverDetailsEventReceived(
          DriverLocationUpdated(
            driverId: otherDriverId,
            latitude: 30.0,
            longitude: 48.0,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
      );

      expect(viewModel.state.location, initialLocation);
    });

    test('patches valid realtime location event locally', () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());

      final updatedTime = DateTime.now().toUtc();
      await viewModel.doIntent(
        RealtimeDriverDetailsEventReceived(
          DriverLocationUpdated(
            driverId: driverId,
            latitude: 29.3500,
            longitude: 47.9900,
            speed: 60.0,
            timestamp: updatedTime,
          ),
        ),
      );

      expect(viewModel.state.location?.latitude, 29.3500);
      expect(viewModel.state.location?.longitude, 47.9900);
      expect(viewModel.state.location?.speed, 60.0);
      // REST street/area names are preserved!
      expect(viewModel.state.location?.streetName, 'شارع الملك فهد');
    });

    test('rejects realtime location event with invalid coordinates', () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      final initialLocation = viewModel.state.location;

      await viewModel.doIntent(
        RealtimeDriverDetailsEventReceived(
          DriverLocationUpdated(
            driverId: driverId,
            latitude: 95.0, // Invalid latitude (> 90)
            longitude: 47.9900,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
      );

      expect(viewModel.state.location, initialLocation);
    });

    test('driver-status-updated patches status text and triggers reconciliation when count changes',
        () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      final completer = Completer<void>();
      repo.delayCompleter = completer;

      await viewModel.doIntent(
        RealtimeDriverDetailsEventReceived(
          DriverStatusUpdated(
            driverId: driverId,
            status: DispatcherMapDriverStatus.inDelivery,
            statusText: 'في الطريق',
            activeBoxesCount: 5,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
      );

      expect(viewModel.state.details?.driver.statusText, 'في الطريق');
      expect(viewModel.state.details?.driver.status,
          DriverDetailsStatus.delivering);

      completer.complete();
      await pumpEventQueue();

      // Triggers reconciliation for details and boxes
      expect(repo.detailsCalls, 2);
      expect(repo.boxesCalls, 2);
      // Does not refetch current location
      expect(repo.locationCalls, 1);
    });

    test('matching box-assigned triggers reconciliation of details and boxes',
        () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      expect(repo.detailsCalls, 1);
      expect(repo.boxesCalls, 1);

      await viewModel.doIntent(
        RealtimeDriverDetailsEventReceived(
          DriverBoxAssigned(
            driverId: driverId,
            boxId: '3c19356d-f432-47d5-89f5-7e82845c8531',
            boxCode: 'BX-10256',
            timestamp: DateTime.now().toUtc(),
          ),
        ),
      );

      expect(repo.detailsCalls, 2);
      expect(repo.boxesCalls, 2);
    });

    test('lifecycle pause releases lease; resume re-acquires and reconciles',
        () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      expect(realtimeClient.acquiredOwners, contains('driver-details:$driverId'));

      await viewModel.doIntent(const DriverDetailsLifecyclePaused());
      expect(realtimeClient.releasedOwners, contains('driver-details:$driverId'));

      await viewModel.doIntent(const DriverDetailsLifecycleResumed());
      expect(realtimeClient.acquiredOwners.where((o) => o == 'driver-details:$driverId').length, 2);
      expect(repo.detailsCalls, 2);
      expect(repo.boxesCalls, 2);
      expect(repo.locationCalls, 2);
    });

    test('close releases realtime owner without disposing shared client', () async {
      await viewModel.doIntent(const LoadDriverDetailsEvent());
      await viewModel.close();

      expect(realtimeClient.releasedOwners, contains('driver-details:$driverId'));
    });
  });
}
