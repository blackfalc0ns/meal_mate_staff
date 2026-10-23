import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/data/mapper/driver_support_mapper.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/data/models/response/driver_support_add_photos_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/data/models/response/driver_support_issue_details_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/data/models/response/driver_support_issue_summary_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/data/models/response/driver_support_issues_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/data/models/response/driver_support_timeline_step_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_timeline_step.dart';

void main() {
  group('DriverSupportMapper Tests', () {
    test('mapStatus handles known and unknown statuses defensively', () {
      expect(
        DriverSupportMapper.mapStatus('UnderReview'),
        equals(DriverSupportTicketStatus.underReview),
      );
      expect(
        DriverSupportMapper.mapStatus('AwaitingReply'),
        equals(DriverSupportTicketStatus.awaitingResponse),
      );
      expect(
        DriverSupportMapper.mapStatus('Resolved'),
        equals(DriverSupportTicketStatus.resolved),
      );
      expect(
        DriverSupportMapper.mapStatus('UnknownStatus'),
        equals(DriverSupportTicketStatus.underReview),
      );
      expect(
        DriverSupportMapper.mapStatus(null),
        equals(DriverSupportTicketStatus.underReview),
      );
    });

    test('mapTimelineState maps Current, Completed, and Unrecorded correctly', () {
      expect(
        DriverSupportMapper.mapTimelineState('Current'),
        equals(DriverTicketStepState.inProgress),
      );
      expect(
        DriverSupportMapper.mapTimelineState('Completed'),
        equals(DriverTicketStepState.completed),
      );
      expect(
        DriverSupportMapper.mapTimelineState('Unrecorded'),
        equals(DriverTicketStepState.pending),
      );
      expect(
        DriverSupportMapper.mapTimelineState('Unknown'),
        equals(DriverTicketStepState.pending),
      );
      expect(
        DriverSupportMapper.mapTimelineState(null),
        equals(DriverTicketStepState.pending),
      );
    });

    test('mapIssuesPageToEntity maps all fields, ignores invalid issue ids, and handles nulls', () {
      const dto = DriverSupportIssuesResponseDto(
        allCount: 5,
        underReviewCount: 2,
        awaitingReplyCount: 1,
        resolvedCount: 2,
        totalCount: 5,
        pageNumber: 1,
        pageSize: 20,
        issues: [
          DriverSupportIssueSummaryDto(
            issueId: '00000000-0000-0000-0000-000000000001',
            category: 'VehicleBreakdown',
            categoryLabel: 'عطل في المركبة',
            title: 'عطل إطار',
            status: 'AwaitingReply',
            statusLabel: 'بانتظار الرد',
            submittedAtUtc: '2026-10-21T08:00:00Z',
            orderCode: '#ORD-101',
          ),
          DriverSupportIssueSummaryDto(
            issueId: null, // Should be filtered out
            category: 'Other',
          ),
          DriverSupportIssueSummaryDto(
            issueId: '', // Should be filtered out
            category: 'Other',
          ),
        ],
      );

      final entity = DriverSupportMapper.mapIssuesPageToEntity(dto);

      expect(entity.allCount, equals(5));
      expect(entity.underReviewCount, equals(2));
      expect(entity.awaitingReplyCount, equals(1));
      expect(entity.resolvedCount, equals(2));
      expect(entity.totalCount, equals(5));
      expect(entity.pageNumber, equals(1));
      expect(entity.pageSize, equals(20));
      expect(entity.hasMore, isFalse);
      expect(entity.issues.length, equals(1));

      final first = entity.issues.first;
      expect(first.id, equals('00000000-0000-0000-0000-000000000001'));
      expect(first.category, equals('VehicleBreakdown'));
      expect(first.categoryLabel, equals('عطل في المركبة'));
      expect(first.title, equals('عطل إطار'));
      expect(first.status, equals(DriverSupportTicketStatus.awaitingResponse));
      expect(first.statusLabel, equals('بانتظار الرد'));
      expect(first.boxNumber, equals('#ORD-101'));
      expect(first.orderCode, equals('#ORD-101'));
      expect(first.submittedAtUtc, isNotNull);
      expect(first.submittedAtUtc!.isUtc, isTrue);
    });

    test('mapDetailsToEntity maps details correctly without faking dates or orders', () {
      const dto = DriverSupportIssueDetailsResponseDto(
        issueId: '00000000-0000-0000-0000-000000000002',
        category: 'VehicleBreakdown',
        categoryLabel: 'عطل في المركبة',
        title: 'عطل مفاجئ',
        description: 'توقف المحرك',
        status: 'UnderReview',
        rawStatus: 'Submitted',
        statusLabel: 'قيد المراجعة',
        submittedAtUtc: '2026-10-21T08:00:00Z',
        updatedAtUtc: null,
        orderCode: null,
        address: null,
        area: null,
        orderCreatedAtUtc: null,
        timeline: [
          DriverSupportTimelineStepDto(
            stage: 'Submitted',
            label: 'تم الإرسال',
            state: 'Completed',
            occurredAtUtc: '2026-10-21T08:00:00Z',
          ),
          DriverSupportTimelineStepDto(
            stage: 'UnderReview',
            label: 'قيد المراجعة',
            state: 'Current',
            occurredAtUtc: null,
          ),
          DriverSupportTimelineStepDto(
            stage: 'Resolved',
            label: 'تم الحل',
            state: 'Unrecorded',
            occurredAtUtc: null,
          ),
        ],
        evidenceUrls: ['https://example.com/img1.png'],
        resolutionNotes: null,
        resolvedAtUtc: null,
        canContactSupport: false,
        contactChannel: null,
      );

      final entity = DriverSupportMapper.mapDetailsToEntity(dto);

      expect(entity.issueId, equals('00000000-0000-0000-0000-000000000002'));
      expect(entity.title, equals('عطل مفاجئ'));
      expect(entity.description, equals('توقف المحرك'));
      expect(entity.status, equals(DriverSupportTicketStatus.underReview));
      expect(entity.rawStatus, equals('Submitted'));
      expect(entity.statusLabel, equals('قيد المراجعة'));
      expect(entity.orderCode, isNull);
      expect(entity.address, isNull);
      expect(entity.area, isNull);
      expect(entity.orderCreatedAtUtc, isNull);
      expect(entity.resolutionNotes, isNull);
      expect(entity.resolvedAtUtc, isNull);
      expect(entity.canContactSupport, isFalse);
      expect(entity.contactChannel, isNull);
      expect(entity.evidenceUrls, equals(['https://example.com/img1.png']));
      expect(entity.isTerminal, isFalse);
      expect(entity.canAddPhotos, isTrue);

      expect(entity.timeline.length, equals(3));
      expect(entity.timeline[0].state, equals(DriverTicketStepState.completed));
      expect(entity.timeline[0].timestamp, isNotNull);
      expect(entity.timeline[1].state, equals(DriverTicketStepState.inProgress));
      expect(entity.timeline[1].timestamp, isNull);
      expect(entity.timeline[2].state, equals(DriverTicketStepState.pending));
      expect(entity.timeline[2].timestamp, isNull);
    });

    test('mapAddPhotosResultToEntity maps result correctly', () {
      const dto = DriverSupportAddPhotosResponseDto(
        issueId: '123',
        status: 'Resolved',
        evidenceUrls: ['key1', 'key2'],
      );

      final entity = DriverSupportMapper.mapAddPhotosResultToEntity(dto);

      expect(entity.issueId, equals('123'));
      expect(entity.status, equals(DriverSupportTicketStatus.resolved));
      expect(entity.evidenceUrls, equals(['key1', 'key2']));
    });
  });
}
