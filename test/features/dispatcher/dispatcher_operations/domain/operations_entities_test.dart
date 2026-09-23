import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_customer_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_indicator_color.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_page_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart';

void main() {
  group('OperationStatus', () {
    test('maps exact API values', () {
      expect(OperationStatus.all.apiValue, 'All');
      expect(OperationStatus.completed.apiValue, 'Completed');
      expect(OperationStatus.cancelled.apiValue, 'Cancelled');
      expect(OperationStatus.failed.apiValue, 'Failed');
      expect(OperationStatus.reassigned.apiValue, 'Reassigned');
      expect(OperationStatus.unknown.apiValue, 'Unknown');
    });

    test('parses known values, aliases, and unknown fallbacks safely', () {
      expect(OperationStatusX.fromApi('Completed'), OperationStatus.completed);
      expect(OperationStatusX.fromApi('Failed'), OperationStatus.failed);
      expect(
        OperationStatusX.fromApi('Reassigned'),
        OperationStatus.reassigned,
      );
      expect(OperationStatusX.fromApi('Cancelled'), OperationStatus.cancelled);
      expect(
        OperationStatusX.fromApi('CancelledByRestaurant'),
        OperationStatus.cancelled,
      );
      expect(
        OperationStatusX.fromApi('cancelled_by_user'),
        OperationStatus.cancelled,
      );
      expect(OperationStatusX.fromApi('All'), OperationStatus.all);
      expect(OperationStatusX.fromApi('future-value'), OperationStatus.unknown);
      expect(OperationStatusX.fromApi(null), OperationStatus.unknown);
    });
  });

  group('OperationsDatePreset', () {
    test('maps exact API values and parses correctly', () {
      expect(OperationsDatePreset.today.apiValue, 'Today');
      expect(OperationsDatePreset.last7Days.apiValue, 'Last7Days');
      expect(OperationsDatePreset.last30Days.apiValue, 'Last30Days');
      expect(OperationsDatePreset.custom.apiValue, 'Custom');
      expect(OperationsDatePreset.all.apiValue, 'All');

      expect(
        OperationsDatePresetX.fromApi('Today'),
        OperationsDatePreset.today,
      );
      expect(
        OperationsDatePresetX.fromApi('Last7Days'),
        OperationsDatePreset.last7Days,
      );
      expect(
        OperationsDatePresetX.fromApi('Last30Days'),
        OperationsDatePreset.last30Days,
      );
      expect(
        OperationsDatePresetX.fromApi('Custom'),
        OperationsDatePreset.custom,
      );
      expect(OperationsDatePresetX.fromApi('All'), OperationsDatePreset.all);
      expect(
        OperationsDatePresetX.fromApi('unknown'),
        OperationsDatePreset.last7Days,
      );
    });
  });

  group('OperationsIndicatorColor', () {
    test('parses typed colors safely', () {
      expect(
        OperationsIndicatorColorX.fromApi('green'),
        OperationsIndicatorColor.green,
      );
      expect(
        OperationsIndicatorColorX.fromApi('orange'),
        OperationsIndicatorColor.orange,
      );
      expect(
        OperationsIndicatorColorX.fromApi('red'),
        OperationsIndicatorColor.red,
      );
      expect(
        OperationsIndicatorColorX.fromApi('grey'),
        OperationsIndicatorColor.grey,
      );
      expect(
        OperationsIndicatorColorX.fromApi('gray'),
        OperationsIndicatorColor.grey,
      );
      expect(
        OperationsIndicatorColorX.fromApi('blue'),
        OperationsIndicatorColor.unknown,
      );
      expect(
        OperationsIndicatorColorX.fromApi(null),
        OperationsIndicatorColor.unknown,
      );
    });
  });

  group('OperationsQueryEntity', () {
    test('validates custom date range correctly', () {
      expect(
        const OperationsQueryEntity(
          datePreset: OperationsDatePreset.custom,
        ).isValid,
        isFalse,
      );

      final now = DateTime.utc(2026, 9, 23);
      final earlier = DateTime.utc(2026, 9, 20);

      expect(
        OperationsQueryEntity(
          datePreset: OperationsDatePreset.custom,
          fromDateUtc: earlier,
          toDateUtc: now,
        ).isValid,
        isTrue,
      );

      // Inverted range is invalid
      expect(
        OperationsQueryEntity(
          datePreset: OperationsDatePreset.custom,
          fromDateUtc: now,
          toDateUtc: earlier,
        ).isValid,
        isFalse,
      );

      // Preset other than custom is valid even without dates
      expect(
        const OperationsQueryEntity(
          datePreset: OperationsDatePreset.last7Days,
        ).isValid,
        isTrue,
      );
    });

    test('resetToFirstPage resets pageNumber to 1', () {
      const query = OperationsQueryEntity(pageNumber: 4);
      expect(query.resetToFirstPage().pageNumber, 1);
    });

    test('copyWith works correctly with nullable clearing', () {
      final now = DateTime.utc(2026, 9, 23);
      final query = OperationsQueryEntity(
        fromDateUtc: now,
        toDateUtc: now,
        search: '10256',
      );
      final updated = query.copyWith(clearCustomDates: true, search: '');
      expect(updated.fromDateUtc, isNull);
      expect(updated.toDateUtc, isNull);
      expect(updated.search, '');
    });
  });

  group('OperationItemEntity and OperationsPageEntity', () {
    test('instantiates with expected fields', () {
      const customer = OperationsCustomerEntity(
        id: 'cust-1',
        name: 'شهد المطيري',
        area: 'حي الملقا',
        addressText: 'حي الملقا، الرياض',
      );
      const driver = OperationsDriverEntity(
        id: 'drv-1',
        name: 'يوسف خالد',
        avatarUrl: 'https://example.com/avatar.jpg',
        indicatorColor: OperationsIndicatorColor.green,
      );
      final occurredAt = DateTime.utc(2026, 9, 23, 10, 30);
      final item = OperationItemEntity(
        id: 'op-1',
        boxId: 'bx-id-1',
        boxCode: '#BX-10256',
        status: OperationStatus.completed,
        customer: customer,
        timeText: '10:30 ص',
        occurredAtUtc: occurredAt,
        driver: driver,
      );

      expect(item.boxCode, '#BX-10256');
      expect(item.boxId, 'bx-id-1');
      expect(item.driver?.name, 'يوسف خالد');
      expect(item.driver?.indicatorColor, OperationsIndicatorColor.green);

      const counters = OperationsCountersEntity(
        allCount: 128,
        completedCount: 98,
        cancelledCount: 3,
        failedCount: 7,
        reassignedCount: 17,
      );
      const pagination = OperationsPaginationEntity(
        pageNumber: 1,
        pageSize: 10,
        totalItems: 128,
        totalPages: 13,
        hasPreviousPage: false,
        hasNextPage: true,
      );

      final page = OperationsPageEntity(
        counters: counters,
        operations: [item],
        pagination: pagination,
      );

      expect(page.counters.allCount, 128);
      expect(page.operations.length, 1);
      expect(page.pagination.hasNextPage, isTrue);
    });
  });
}
