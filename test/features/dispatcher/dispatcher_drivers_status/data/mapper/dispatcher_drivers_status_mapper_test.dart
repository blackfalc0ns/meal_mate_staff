import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/mapper/dispatcher_drivers_status_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/dispatcher_drivers_status_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/response/update_driver_availability_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_sort.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';

void main() {
  group('DispatcherDriverStatusType mapping', () {
    test('fromApi handles operational states case-insensitively', () {
      expect(
        DispatcherDriverStatusType.fromApi('Available'),
        DispatcherDriverStatusType.available,
      );
      expect(
        DispatcherDriverStatusType.fromApi('available'),
        DispatcherDriverStatusType.available,
      );
      expect(
        DispatcherDriverStatusType.fromApi('InDelivery'),
        DispatcherDriverStatusType.inDelivery,
      );
      expect(
        DispatcherDriverStatusType.fromApi('indelivery'),
        DispatcherDriverStatusType.inDelivery,
      );
      expect(
        DispatcherDriverStatusType.fromApi('in_delivery'),
        DispatcherDriverStatusType.inDelivery,
      );
      expect(
        DispatcherDriverStatusType.fromApi('Unavailable'),
        DispatcherDriverStatusType.unavailable,
      );
      expect(
        DispatcherDriverStatusType.fromApi('unavailable'),
        DispatcherDriverStatusType.unavailable,
      );
    });

    test('fromApi maps unknown input to unknown, never available', () {
      expect(
        DispatcherDriverStatusType.fromApi('RandomString'),
        DispatcherDriverStatusType.unknown,
      );
      expect(
        DispatcherDriverStatusType.fromApi(null),
        DispatcherDriverStatusType.unknown,
      );
    });

    test('apiValue matches backend query contract', () {
      expect(DispatcherDriverStatusType.available.apiValue, 'Available');
      expect(DispatcherDriverStatusType.inDelivery.apiValue, 'InDelivery');
      expect(DispatcherDriverStatusType.unavailable.apiValue, 'Unavailable');
      expect(DispatcherDriverStatusType.unknown.apiValue, 'All');
    });
  });

  group('Sort and Query defaults', () {
    test('sort apiValue matches backend contract', () {
      expect(DispatcherDriversStatusSort.name.apiValue, 'Name');
      expect(DispatcherDriversStatusSort.ratingDesc.apiValue, 'RatingDesc');
      expect(DispatcherDriversStatusSort.newest.apiValue, 'Newest');
      expect(DispatcherDriversStatusSort.status.apiValue, 'Status');
    });

    test('query defaults to page 1 and page size 15', () {
      const query = DispatcherDriversStatusQueryEntity();
      expect(query.pageNumber, 1);
      expect(query.pageSize, 15);
      expect(query.sortBy, DispatcherDriversStatusSort.name);
      expect(query.status, isNull);
      expect(query.search, isNull);
    });
  });

  group('DispatcherDriversStatusMapper', () {
    const baseUrl = 'http://maelmate.runasp.net';

    test('maps full response correctly', () {
      const dto = DispatcherDriversStatusResponseDto(
        counts: DispatcherDriversStatusCountsDto(
          total: 24,
          available: 12,
          inDelivery: 8,
          unavailable: 4,
        ),
        items: [
          DispatcherDriverStatusItemDto(
            driverId: 'd-1',
            driverCode: 'DR-101',
            fullName: 'محمد علي',
            phoneNumber: '+96512345678',
            avatarStorageKey: 'uploads/driver.png',
            isAvailable: true,
            operationalStatus: 'Available',
            rating: 4.9,
            ratingsCount: 50,
            vehicleType: 'Car',
            vehicleModel: 'Camry',
            vehiclePlate: '1234',
          ),
        ],
        pagination: DispatcherDriversPaginationDto(
          pageNumber: 1,
          pageSize: 15,
          totalItems: 24,
          totalPages: 2,
          hasPreviousPage: false,
          hasNextPage: true,
        ),
      );

      final summary = DispatcherDriversStatusMapper.toEntity(
        dto,
        baseUrl: baseUrl,
      );

      expect(summary.counts.total, 24);
      expect(summary.counts.available, 12);
      expect(summary.counts.inDelivery, 8);
      expect(summary.counts.unavailable, 4);

      expect(summary.items.length, 1);
      final item = summary.items.first;
      expect(item.driverId, 'd-1');
      expect(item.driverCode, 'DR-101');
      expect(item.fullName, 'محمد علي');
      expect(item.phoneNumber, '+96512345678');
      expect(item.avatarUrl, 'http://maelmate.runasp.net/uploads/driver.png');
      expect(item.isAvailable, isTrue);
      expect(item.operationalStatus, DispatcherDriverStatusType.available);
      expect(item.rating, 4.9);
      expect(item.ratingsCount, 50);
      expect(item.vehicleType, 'Car');
      expect(item.vehicleModel, 'Camry');
      expect(item.vehiclePlate, '1234');

      expect(summary.pagination.pageNumber, 1);
      expect(summary.pagination.pageSize, 15);
      expect(summary.pagination.totalItems, 24);
      expect(summary.pagination.totalPages, 2);
      expect(summary.pagination.hasPreviousPage, isFalse);
      expect(summary.pagination.hasNextPage, isTrue);
    });

    test(
      'clamps negative counts to 0 and defaults null items to empty list',
      () {
        const dto = DispatcherDriversStatusResponseDto(
          counts: DispatcherDriversStatusCountsDto(
            total: -5,
            available: -1,
            inDelivery: 0,
            unavailable: null,
          ),
          items: null,
          pagination: null,
        );

        final summary = DispatcherDriversStatusMapper.toEntity(dto);
        expect(summary.counts.total, 0);
        expect(summary.counts.available, 0);
        expect(summary.counts.inDelivery, 0);
        expect(summary.counts.unavailable, 0);
        expect(summary.items, isEmpty);
        expect(summary.pagination.pageNumber, 1);
      },
    );

    test('preserves null rating and null phone as null', () {
      const dto = DispatcherDriversStatusResponseDto(
        items: [
          DispatcherDriverStatusItemDto(
            driverId: 'd-2',
            rating: null,
            phoneNumber: null,
          ),
        ],
      );

      final summary = DispatcherDriversStatusMapper.toEntity(dto);
      final item = summary.items.first;
      expect(item.rating, isNull);
      expect(item.phoneNumber, isNull);
    });

    test('resolves avatar keys correctly', () {
      expect(
        DispatcherDriversStatusMapper.resolveAvatarUrl(null, baseUrl: baseUrl),
        isNull,
      );
      expect(
        DispatcherDriversStatusMapper.resolveAvatarUrl('', baseUrl: baseUrl),
        isNull,
      );
      expect(
        DispatcherDriversStatusMapper.resolveAvatarUrl(
          'https://external.com/avatar.jpg',
          baseUrl: baseUrl,
        ),
        'https://external.com/avatar.jpg',
      );
      expect(
        DispatcherDriversStatusMapper.resolveAvatarUrl(
          'uploads/photo.jpg',
          baseUrl: baseUrl,
        ),
        'http://maelmate.runasp.net/uploads/photo.jpg',
      );
      expect(
        DispatcherDriversStatusMapper.resolveAvatarUrl(
          '/uploads/photo.jpg',
          baseUrl: baseUrl,
        ),
        'http://maelmate.runasp.net/uploads/photo.jpg',
      );
    });

    test('maps toggle request entity to DTO', () {
      const entity = UpdateDriverAvailabilityRequestEntity(
        driverId: 'drv-1',
        isAvailable: false,
        reason: ' Lunch break ',
      );
      final dto = entity.toDto();
      expect(dto.isAvailable, false);
      expect(dto.reason, 'Lunch break');

      const blankReason = UpdateDriverAvailabilityRequestEntity(
        driverId: 'drv-1',
        isAvailable: true,
        reason: '   ',
      );
      expect(blankReason.toDto().reason, isNull);
    });

    test('maps toggle response DTO to result entity', () {
      const dto = UpdateDriverAvailabilityResponseDto(
        driverId: 'drv-1',
        isAvailable: true,
        operationalStatus: 'Available',
        updatedAtUtc: '2026-09-27T12:00:00Z',
      );

      final result = DispatcherDriversStatusMapper.toAvailabilityResult(dto);
      expect(result.driverId, 'drv-1');
      expect(result.isAvailable, true);
      expect(result.operationalStatus, DispatcherDriverStatusType.available);
      expect(
        result.updatedAtUtc,
        DateTime.parse('2026-09-27T12:00:00Z').toUtc(),
      );
    });

    test('handles malformed date in toggle response', () {
      const dto = UpdateDriverAvailabilityResponseDto(
        driverId: 'drv-1',
        isAvailable: true,
        operationalStatus: 'Available',
        updatedAtUtc: 'not-a-date',
      );

      final result = DispatcherDriversStatusMapper.toAvailabilityResult(dto);
      expect(result.updatedAtUtc, isNull);
    });
  });
}
