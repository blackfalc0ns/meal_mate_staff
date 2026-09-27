import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/data_source/dispatcher_drivers_status_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/realtime/driver_availability_updated_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/request/update_driver_availability_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_driver_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_drivers_status_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/update_driver_availability_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_realtime_client.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/repo/dispatcher_drivers_status_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';

class FakeRemoteDataSource implements DispatcherDriversStatusRemoteDataSource {
  DispatcherDriversStatusResponseDto? mockStatusResponse;
  UpdateDriverAvailabilityResponseDto? mockToggleResponse;
  DispatcherDriverDetailsResponseDto? mockDetailsResponse;
  Exception? errorToThrow;

  String? lastSearch;
  String? lastStatus;
  String? lastSortBy;
  int? lastPageNumber;
  int? lastPageSize;

  String? lastDriverId;
  UpdateDriverAvailabilityRequestDto? lastToggleRequest;

  @override
  Future<DispatcherDriversStatusResponseDto> getDriversStatus({
    String? search,
    String status = 'All',
    String sortBy = 'Name',
    int pageNumber = 1,
    int pageSize = 15,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastSearch = search;
    lastStatus = status;
    lastSortBy = sortBy;
    lastPageNumber = pageNumber;
    lastPageSize = pageSize;
    return mockStatusResponse ?? const DispatcherDriversStatusResponseDto();
  }

  @override
  Future<UpdateDriverAvailabilityResponseDto> updateDriverAvailability(
    String driverId,
    UpdateDriverAvailabilityRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastDriverId = driverId;
    lastToggleRequest = request;
    return mockToggleResponse ??
        const UpdateDriverAvailabilityResponseDto(
          driverId: 'drv-1',
          isAvailable: true,
          operationalStatus: 'Available',
        );
  }

  @override
  Future<DispatcherDriverDetailsResponseDto> getDriverDetails(
    String driverId,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastDriverId = driverId;
    return mockDetailsResponse ??
        const DispatcherDriverDetailsResponseDto(
          driver: DispatcherDriverDetailsProfileDto(
            driverId: 'drv-1',
            fullName: 'Driver One',
          ),
        );
  }
}

class FakeRealtimeClient implements DispatcherDriversStatusRealtimeClient {
  final StreamController<DriverAvailabilityUpdatedEventDto> controller =
      StreamController<DriverAvailabilityUpdatedEventDto>.broadcast();

  final List<String> acquiredOwners = [];
  final List<String> releasedOwners = [];

  @override
  Stream<DriverAvailabilityUpdatedEventDto> get events => controller.stream;

  @override
  Future<void> acquire(String ownerId) async {
    acquiredOwners.add(ownerId);
  }

  @override
  Future<void> release(String ownerId) async {
    releasedOwners.add(ownerId);
  }

  @override
  Future<void> dispose() async {
    await controller.close();
  }
}

void main() {
  late FakeRemoteDataSource remote;
  late FakeRealtimeClient realtime;
  late DispatcherDriversStatusRepositoryImpl repository;

  setUp(() {
    remote = FakeRemoteDataSource();
    realtime = FakeRealtimeClient();
    repository = DispatcherDriversStatusRepositoryImpl(remote, realtime);
  });

  tearDown(() async {
    await realtime.dispose();
  });

  group('getDriversStatus', () {
    test('forwards query parameters and maps DTO to entity', () async {
      remote.mockStatusResponse = const DispatcherDriversStatusResponseDto(
        counts: DispatcherDriversStatusCountsDto(
          total: 10,
          available: 5,
          inDelivery: 3,
          unavailable: 2,
        ),
        items: [
          DispatcherDriverStatusItemDto(
            driverId: 'd-1',
            driverCode: 'DR-1',
            fullName: 'Driver 1',
            isAvailable: true,
            operationalStatus: 'Available',
          ),
        ],
        pagination: DispatcherDriversPaginationDto(
          pageNumber: 2,
          pageSize: 10,
          totalItems: 10,
          totalPages: 1,
        ),
      );

      final result = await repository.getDriversStatus(
        const DispatcherDriversStatusQueryEntity(
          search: 'ahmed',
          status: DispatcherDriverStatusType.available,
          pageNumber: 2,
          pageSize: 10,
        ),
      );

      expect(remote.lastSearch, 'ahmed');
      expect(remote.lastStatus, 'Available');
      expect(remote.lastPageNumber, 2);
      expect(remote.lastPageSize, 10);

      expect(result, isA<ApiSuccessResult>());
      final summary = (result as ApiSuccessResult).data;
      expect(summary.counts.total, 10);
      expect(summary.items.first.driverId, 'd-1');
      expect(summary.pagination.pageNumber, 2);
    });

    test('catches DioException and returns ApiErrorResult', () async {
      remote.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/dispatcher/drivers'),
        type: DioExceptionType.connectionTimeout,
      );

      final result = await repository.getDriversStatus();
      expect(result, isA<ApiErrorResult>());
    });
  });

  group('toggleDriverAvailability', () {
    test('forwards request and maps response to entity', () async {
      remote.mockToggleResponse = const UpdateDriverAvailabilityResponseDto(
        driverId: 'd-1',
        isAvailable: false,
        operationalStatus: 'Unavailable',
        updatedAtUtc: '2026-09-27T12:00:00Z',
      );

      final result = await repository.toggleDriverAvailability(
        const UpdateDriverAvailabilityRequestEntity(
          driverId: 'd-1',
          isAvailable: false,
          reason: 'break',
        ),
      );

      expect(remote.lastDriverId, 'd-1');
      expect(remote.lastToggleRequest?.isAvailable, false);
      expect(remote.lastToggleRequest?.reason, 'break');

      expect(result, isA<ApiSuccessResult>());
      final entity = (result as ApiSuccessResult).data;
      expect(entity.driverId, 'd-1');
      expect(entity.isAvailable, false);
      expect(entity.operationalStatus, DispatcherDriverStatusType.unavailable);
    });
  });

  group('getDriverDetails', () {
    test('forwards driverId and maps response to entity', () async {
      remote.mockDetailsResponse = const DispatcherDriverDetailsResponseDto(
        driver: DispatcherDriverDetailsProfileDto(
          driverId: 'd-100',
          fullName: 'Test Driver',
          isAvailable: true,
          operationalStatus: 'Available',
        ),
      );

      final result = await repository.getDriverDetails('d-100');
      expect(remote.lastDriverId, 'd-100');
      expect(result, isA<ApiSuccessResult>());
      final details = (result as ApiSuccessResult).data;
      expect(details.id, 'd-100');
      expect(details.name, 'Test Driver');
    });
  });

  group('realtime lifecycle and updates', () {
    test('acquires and releases owner', () async {
      await repository.acquireRealtime('screen-1');
      expect(realtime.acquiredOwners, contains('screen-1'));

      await repository.releaseRealtime('screen-1');
      expect(realtime.releasedOwners, contains('screen-1'));
    });

    test('transforms realtime event stream into entity stream', () async {
      final expectation = expectLater(
        repository.driverAvailabilityUpdates,
        emits(
          predicate<dynamic>((val) {
            return val.driverId == 'drv-42' &&
                val.isAvailable == true &&
                val.operationalStatus == DispatcherDriverStatusType.available;
          }),
        ),
      );

      realtime.controller.add(
        const DriverAvailabilityUpdatedEventDto(
          driverId: 'drv-42',
          isAvailable: true,
          operationalStatus: 'Available',
        ),
      );

      await expectation;
    });
  });
}
