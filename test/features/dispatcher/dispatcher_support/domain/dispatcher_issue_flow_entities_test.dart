import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_support_route_arguments.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_attachment_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_resolution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_trip_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_workflow_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidate_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/resolve_issue_result_entity.dart';

void main() {
  group('Dispatcher Issue Flow Entities Tests', () {
    test('Route arguments require only issueId', () {
      const detailsArgs = DispatcherSupportIssueDetailsRouteArgs(issueId: 'issue-101');
      expect(detailsArgs.issueId, 'issue-101');

      const reassignArgs = DispatcherReassignDriverRouteArgs(issueId: 'issue-102');
      expect(reassignArgs.issueId, 'issue-102');
    });

    test('DispatcherIssueStatus parsing and fallback', () {
      expect(DispatcherIssueStatusX.fromApi('Resolved'), DispatcherIssueStatus.resolved);
      expect(DispatcherIssueStatusX.fromApi('RESOLVED'), DispatcherIssueStatus.resolved);
      expect(DispatcherIssueStatusX.fromApi('closed'), DispatcherIssueStatus.resolved);
      expect(DispatcherIssueStatusX.fromApi('Open'), DispatcherIssueStatus.open);
      expect(DispatcherIssueStatusX.fromApi('InProgress'), DispatcherIssueStatus.inProgress);
      expect(DispatcherIssueStatusX.fromApi('in_progress'), DispatcherIssueStatus.inProgress);
      expect(DispatcherIssueStatusX.fromApi('in-progress'), DispatcherIssueStatus.inProgress);
      expect(DispatcherIssueStatusX.fromApi('future-value'), DispatcherIssueStatus.unknown);
      expect(DispatcherIssueStatusX.fromApi(null), DispatcherIssueStatus.unknown);
    });

    test('DispatcherIssueDetailEntity status and resolved-state derivation', () {
      const openIssue = DispatcherIssueDetailEntity(
        issueId: 'iss-1',
        title: 'Vehicle Flat Tire',
        category: 'VEHICLE_BREAKDOWN',
        categoryLabel: 'عطل مركبة',
        categoryColorHex: '#EF4444',
        createdAtUtc: null,
        reportedTimeText: 'منذ 10 دقائق',
        status: DispatcherIssueStatus.open,
        statusLabel: 'مفتوحة',
        boxCode: 'BOX-998',
        area: 'الرياض - حي الملز',
        affectedBoxesCount: 3,
        affectedBoxesText: '3 صناديق متأثرة',
        priority: 'HIGH',
        priorityText: 'عاجل',
        priorityColorHex: '#EF4444',
        driver: DispatcherIssueDriverEntity(
          id: 'driver-1',
          name: 'أحمد محمود',
          code: 'DRV-101',
          avatarUrl: 'https://example.com/avatar.jpg',
          isOnline: true,
          status: 'online',
          statusLabel: 'متصل الآن',
          subStatus: 'في طريق التسليم',
        ),
        description: 'انفجار الإطار الخلفي',
        evidencePhotos: [
          DispatcherIssueAttachmentEntity(
            id: 'att-1',
            url: 'https://example.com/original.jpg',
            thumbnailUrl: 'https://example.com/thumb.jpg',
          ),
        ],
        tripInfo: DispatcherIssueTripEntity(
          clientName: 'سارة خالد',
          mealsCount: 2,
          expectedDeliveryTime: '02:30 م',
          pickupLocation: 'مطعم السعادة',
          dropoffLocation: 'حي الملز شارع 14',
        ),
        resolution: null,
      );

      expect(openIssue.isResolved, isFalse);
      expect(openIssue.driver, isNotNull);
      expect(openIssue.driver!.name, 'أحمد محمود');
      expect(openIssue.resolution, isNull);
      expect(openIssue.evidencePhotos.first.url, 'https://example.com/original.jpg');

      final resolvedIssue = openIssue.copyWith(
        status: DispatcherIssueStatus.resolved,
        resolution: DispatcherIssueResolutionEntity(
          resolutionNotes: 'تم تعيين سائق بديل وتوصيل الطلبات',
          resolvedAtUtc: DateTime.utc(2026, 9, 22, 14, 30),
          resolvedAtText: '14:30',
          resolvedBy: 'مشرف العمليات',
        ),
      );

      expect(resolvedIssue.isResolved, isTrue);
      expect(resolvedIssue.resolution, isNotNull);
      expect(resolvedIssue.resolution!.resolutionNotes, contains('سائق بديل'));
    });

    test('DispatcherIssueAttachmentEntity exposes url and thumbnailUrl', () {
      final attachment = DispatcherIssueAttachmentEntity(
        id: 'att-2',
        url: 'https://cdn.example.com/photo.jpg',
        thumbnailUrl: 'https://cdn.example.com/thumb_01.jpg',
        uploadedAtUtc: DateTime.utc(2026, 9, 22, 12, 0),
        orderNumber: 2,
      );

      expect(attachment.url, 'https://cdn.example.com/photo.jpg');
      expect(attachment.thumbnailUrl, 'https://cdn.example.com/thumb_01.jpg');
      expect(attachment.orderNumber, 2);
    });

    test('ReassignDriverCandidateEntity models all candidate attributes', () {
      const candidate = ReassignDriverCandidateEntity(
        id: 'c-1',
        name: 'فهد المطيري',
        code: 'DRV-202',
        avatarUrl: 'https://example.com/driver2.jpg',
        isAvailable: true,
        status: 'AVAILABLE',
        statusText: 'متاح للطلب',
        statusColorHex: '#10B981',
        rating: 4.8,
        activeOrdersCount: 1,
        area: 'حي الملز',
        isSameArea: true,
        distanceKm: 1.5,
        distanceText: '1.5 كم',
        estimatedArrivalMinutes: 6,
        estimatedArrivalText: '6 دقائق',
        vehicleInfo: 'تويوتا يارس - أبيض',
        recommendationRank: 1,
      );

      expect(candidate.isSameArea, isTrue);
      expect(candidate.recommendationRank, 1);
      expect(candidate.distanceKm, 1.5);
      expect(candidate.statusText, 'متاح للطلب');
    });

    test('ReassignDriverCandidatesEntity immutable append with de-duplication', () {
      const summary = ReassignDriverIssueSummaryEntity(
        issueId: 'iss-1',
        title: 'عطل مركبة',
        taskNumber: 'TASK-101',
      );

      const candidate1 = ReassignDriverCandidateEntity(
        id: 'cand-1',
        name: 'سائق 1',
        code: 'DRV-1',
        rating: 4.9,
        distanceKm: 2.0,
      );

      const candidate2 = ReassignDriverCandidateEntity(
        id: 'cand-2',
        name: 'سائق 2',
        code: 'DRV-2',
        rating: 4.7,
        distanceKm: 3.5,
      );

      const candidate3 = ReassignDriverCandidateEntity(
        id: 'cand-3',
        name: 'سائق 3',
        code: 'DRV-3',
        rating: 4.6,
        distanceKm: 4.0,
      );

      const initialPage = ReassignDriverCandidatesEntity(
        summary: summary,
        candidates: [candidate1, candidate2],
        pagination: DispatcherSupportPaginationEntity(
          pageNumber: 1,
          pageSize: 2,
          totalCount: 3,
          totalPages: 2,
          hasNextPage: true,
        ),
      );

      expect(initialPage.candidates.length, 2);

      // Appending page 2 containing candidate2 (duplicate) and candidate3 (new)
      final secondPage = initialPage.copyWithAppendedCandidates(
        newCandidates: [candidate2, candidate3],
        newPagination: const DispatcherSupportPaginationEntity(
          pageNumber: 2,
          pageSize: 2,
          totalCount: 3,
          totalPages: 2,
          hasNextPage: false,
        ),
      );

      expect(secondPage.candidates.length, 3);
      expect(secondPage.candidates.map((c) => c.id).toList(), ['cand-1', 'cand-2', 'cand-3']);
      expect(secondPage.pagination.hasNextPage, isFalse);
    });

    test('Workflow and mutation result entities', () {
      const workflowResult = DispatcherIssueWorkflowResultEntity(
        changed: true,
        requiresRefresh: true,
        issueId: 'issue-10',
      );
      expect(workflowResult.changed, isTrue);
      expect(workflowResult.requiresRefresh, isTrue);

      const resolveResult = ResolveIssueResultEntity(
        issueId: 'issue-10',
        status: DispatcherIssueStatus.resolved,
        statusLabel: 'تم الحل',
        resolution: DispatcherIssueResolutionEntity(
          resolutionNotes: 'ملاحظة الحل',
        ),
      );
      expect(resolveResult.status, DispatcherIssueStatus.resolved);

      const reassignResult = ReassignmentResultEntity(
        issueId: 'issue-10',
        status: DispatcherIssueStatus.resolved,
        statusLabel: 'تم تعيين سائق بديل',
        reassignedDriver: DispatcherIssueDriverEntity(
          id: 'driver-99',
          name: 'سائق جديد',
          code: 'DRV-99',
          isOnline: true,
        ),
      );
      expect(reassignResult.reassignedDriver?.name, 'سائق جديد');

      const request = ReassignDriverRequestEntity(
        replacementDriverId: 'driver-99',
        notes: null,
      );
      expect(request.replacementDriverId, 'driver-99');
      expect(request.notes, isNull);
    });
  });
}
