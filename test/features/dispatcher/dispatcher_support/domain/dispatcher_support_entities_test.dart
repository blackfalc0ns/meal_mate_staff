import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_issue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_status.dart';

void main() {
  group('DispatcherSupportQueryEntity', () {
    test('has expected default values and api serialization', () {
      const query = DispatcherSupportQueryEntity();

      expect(query.status, DispatcherSupportStatus.open);
      expect(query.datePreset, DispatcherSupportDatePreset.last7Days);
      expect(query.pageNumber, 1);
      expect(query.pageSize, 20);
      expect(query.apiStatus, 'Open');
      expect(query.search, '');
      expect(query.area, isNull);
      expect(query.fromDateUtc, isNull);
      expect(query.toDateUtc, isNull);
    });

    test('date preset apiValue maps correctly', () {
      expect(DispatcherSupportDatePreset.today.apiValue, 'Today');
      expect(DispatcherSupportDatePreset.yesterday.apiValue, 'Yesterday');
      expect(DispatcherSupportDatePreset.last7Days.apiValue, 'Last7Days');
      expect(DispatcherSupportDatePreset.last30Days.apiValue, 'Last30Days');
      expect(DispatcherSupportDatePreset.custom.apiValue, 'Custom');
    });

    test('status apiStatus maps correctly for all statuses', () {
      expect(
        const DispatcherSupportQueryEntity(
          status: DispatcherSupportStatus.open,
        ).apiStatus,
        'Open',
      );
      expect(
        const DispatcherSupportQueryEntity(
          status: DispatcherSupportStatus.inProgress,
        ).apiStatus,
        'InProgress',
      );
      expect(
        const DispatcherSupportQueryEntity(
          status: DispatcherSupportStatus.resolved,
        ).apiStatus,
        'Resolved',
      );
    });

    test('resetToFirstPage resets pageNumber to 1', () {
      const query = DispatcherSupportQueryEntity(pageNumber: 3);
      expect(query.pageNumber, 3);
      expect(query.resetToFirstPage().pageNumber, 1);
    });

    test('copyWith updates fields correctly', () {
      const query = DispatcherSupportQueryEntity();
      final updated = query.copyWith(
        area: 'Downtown',
        status: DispatcherSupportStatus.inProgress,
        search: 'box-123',
        datePreset: DispatcherSupportDatePreset.today,
        pageNumber: 2,
        pageSize: 30,
      );

      expect(updated.area, 'Downtown');
      expect(updated.status, DispatcherSupportStatus.inProgress);
      expect(updated.search, 'box-123');
      expect(updated.datePreset, DispatcherSupportDatePreset.today);
      expect(updated.pageNumber, 2);
      expect(updated.pageSize, 30);
    });
  });

  group('DispatcherSupportPaginationEntity', () {
    test('calculates hasNextPage and hasPreviousPage correctly', () {
      const page1 = DispatcherSupportPaginationEntity(
        pageNumber: 1,
        pageSize: 20,
        totalCount: 45,
        totalPages: 3,
        hasNextPage: true,
        hasPreviousPage: false,
      );

      expect(page1.hasNextPage, isTrue);
      expect(page1.hasPreviousPage, isFalse);

      const lastPage = DispatcherSupportPaginationEntity(
        pageNumber: 3,
        pageSize: 20,
        totalCount: 45,
        totalPages: 3,
        hasNextPage: false,
        hasPreviousPage: true,
      );

      expect(lastPage.hasNextPage, isFalse);
      expect(lastPage.hasPreviousPage, isTrue);
    });
  });

  group('DispatcherSupportIssueEntity', () {
    test('constructs with canonical fields and safe fallbacks', () {
      const issue = DispatcherSupportIssueEntity(
        id: 'issue-1',
        boxCode: 'BX-99',
        title: 'Damaged food box',
        issueCategory: 'DamagedBox',
        categoryLabel: 'Damaged Box',
        categoryColor: 0xFFFF5722,
        timeAgo: '10m ago',
        driverId: 'drv-1',
        driverCode: 'D100',
        driverName: 'Ahmed Ali',
        driverAvatar: 'https://cdn.example.com/avatar.png',
        driverPhone: '+966500000000',
        area: 'Al Malqa',
        vehicleInfo: 'Toyota Camry • White',
        vehicleModel: 'Toyota Camry',
        vehicleColor: 'White',
        priority: 'High',
        priorityLabel: 'High Priority',
        priorityColor: 0xFFF44336,
        status: DispatcherSupportStatus.open,
        statusLabel: 'Open',
        issueType: DispatcherSupportIssueType.damagedBox,
      );

      expect(issue.id, 'issue-1');
      expect(issue.boxCode, 'BX-99');
      expect(issue.title, 'Damaged food box');
      expect(issue.issueCategory, 'DamagedBox');
      expect(issue.driverCode, 'D100');
      expect(issue.vehicleInfo, 'Toyota Camry • White');
      expect(issue.priority, 'High');
      expect(issue.status, DispatcherSupportStatus.open);
    });
  });

  group('DispatcherSupportResponseEntity', () {
    test('holds counters, area chips, issues, and pagination', () {
      const response = DispatcherSupportResponseEntity(
        counters: DispatcherSupportKpiEntity(
          currentArea: 'All',
          openCount: 5,
          inProgressCount: 2,
          resolvedCount: 8,
          totalCount: 15,
        ),
        areaChips: [
          DispatcherSupportAreaChipEntity(
            areaKey: 'all',
            displayName: 'All Areas',
            count: 15,
          ),
        ],
        issues: [],
        pagination: DispatcherSupportPaginationEntity(
          pageNumber: 1,
          pageSize: 20,
          totalCount: 0,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );

      expect(response.counters.openCount, 5);
      expect(response.counters.missingCount, 5);
      expect(response.areaChips.first.areaKey, 'all');
      expect(response.pagination.pageNumber, 1);
      expect(response.issues, isEmpty);
    });
  });
}
