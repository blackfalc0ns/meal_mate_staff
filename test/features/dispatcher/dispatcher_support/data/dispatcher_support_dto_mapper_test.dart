import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/mapper/dispatcher_support_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/dispatcher_support_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_status.dart';

void main() {
  group('DispatcherSupportDtoMapper', () {
    test('maps complete canonical backend response correctly', () {
      final json = {
        'counters': {
          'currentArea': 'Al Malqa',
          'openCount': 10,
          'inProgressCount': 4,
          'resolvedCount': 12,
          'totalCount': 26,
        },
        'areaChips': [
          {'areaKey': 'all', 'displayName': 'All', 'count': 26},
          {'areaKey': 'al_malqa', 'displayName': 'Al Malqa', 'count': 10},
        ],
        'issues': [
          {
            'id': 'iss-001',
            'boxCode': 'BOX-101',
            'title': 'Delayed Delivery',
            'issueCategory': 'SevereDelay',
            'categoryLabel': 'Severe Delay',
            'issueCategoryColor': '#F44336',
            'reportedAtUtc': '2026-09-22T10:00:00Z',
            'timeAgo': '15m ago',
            'driverId': 'drv-1',
            'driverCode': 'DRV-100',
            'driverName': 'Tariq Hamed',
            'driverAvatar': 'https://example.com/avatar1.jpg',
            'driverPhone': '+966501112233',
            'area': 'Al Malqa',
            'vehicleInfo': 'Toyota Prius • White',
            'vehicleModel': 'Toyota Prius',
            'vehicleColor': 'White',
            'priority': 'High',
            'priorityLabel': 'Urgent',
            'priorityColor': '#E53935',
            'status': 'Open',
            'statusLabel': 'Open Issue',
            'isDriverActive': true,
          },
        ],
        'pagination': {
          'pageNumber': 1,
          'pageSize': 20,
          'totalCount': 26,
          'totalPages': 2,
          'hasNextPage': true,
          'hasPreviousPage': false,
        },
      };

      final dto = DispatcherSupportResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.counters.openCount, 10);
      expect(entity.counters.inProgressCount, 4);
      expect(entity.counters.resolvedCount, 12);
      expect(entity.counters.totalCount, 26);
      expect(entity.counters.currentArea, 'Al Malqa');

      expect(entity.areaChips.length, 2);
      expect(entity.areaChips[0].areaKey, 'all');
      expect(entity.areaChips[1].displayName, 'Al Malqa');

      expect(entity.issues.length, 1);
      final issue = entity.issues.first;
      expect(issue.id, 'iss-001');
      expect(issue.boxCode, 'BOX-101');
      expect(issue.title, 'Delayed Delivery');
      expect(issue.issueCategory, 'SevereDelay');
      expect(issue.driverName, 'Tariq Hamed');
      expect(issue.driverCode, 'DRV-100');
      expect(issue.vehicleInfo, 'Toyota Prius • White');
      expect(issue.status, DispatcherSupportStatus.open);
      expect(issue.issueType, DispatcherSupportIssueType.severeDelay);
      expect(issue.categoryColor, isNotNull);

      expect(entity.pagination.pageNumber, 1);
      expect(entity.pagination.pageSize, 20);
      expect(entity.pagination.totalPages, 2);
      expect(entity.pagination.hasNextPage, isTrue);
      expect(entity.pagination.hasPreviousPage, isFalse);
    });

    test('resolves compatibility aliases with correct precedence', () {
      final json = {
        'issues': [
          {
            // Primary fields null, aliases present
            'id': null,
            'issueId': 'alias-issue-99',
            'boxCode': null,
            'issueCode': 'BOX-ALIAS-99',
            'issueCategory': null,
            'badgeText': 'DamagedBox',
            'timeAgo': null,
            'reportedTimeText': '45m ago',
            'vehicleInfo': null,
            'vehicleText': 'Hyundai Elantra • Silver',
            'issueCategoryColor': 'invalid-color-value',
            'badgeColor': '#FF9800',
            'driverName': 'Sami Fahd',
            'area': 'Olaya',
            'status': 'InProgress',
          },
        ],
      };

      final dto = DispatcherSupportResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.issues.length, 1);
      final issue = entity.issues.first;
      expect(issue.id, 'alias-issue-99');
      expect(issue.boxCode, 'BOX-ALIAS-99');
      expect(issue.issueCategory, 'DamagedBox');
      expect(issue.timeAgo, '45m ago');
      expect(issue.vehicleInfo, 'Hyundai Elantra • Silver');
      expect(issue.status, DispatcherSupportStatus.inProgress);
      expect(issue.issueType, DispatcherSupportIssueType.damagedBox);
      expect(issue.categoryColor, isNotNull);
    });

    test(
      'handles completely null / malformed fixtures defensively without throwing',
      () {
        final json = <String, dynamic>{
          'counters': null,
          'areaChips': null,
          'issues': null,
          'pagination': null,
        };

        final dto = DispatcherSupportResponseDto.fromJson(json);
        final entity = dto.toEntity();

        expect(entity.counters.openCount, 0);
        expect(entity.areaChips, isEmpty);
        expect(entity.issues, isEmpty);
        expect(entity.pagination.pageNumber, 1);
        expect(entity.pagination.hasNextPage, isFalse);
      },
    );
  });
}
