import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/mapper/dispatcher_issue_details_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/mapper/dispatcher_reassignment_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/reassign_driver_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/resolve_issue_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/dispatcher_issue_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/reassign_driver_candidates_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/reassignment_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/resolve_issue_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';

void main() {
  group('Dispatcher Issue Flow DTO and Mapper Tests', () {
    test('Open issue JSON parsing and mapping', () {
      final json = {
        'issueId': 'iss-001',
        'title': 'عطل محرك السيارة',
        'category': 'VEHICLE_BREAKDOWN',
        'categoryLabel': 'عطل مركبة',
        'categoryColor': '#EF4444',
        'createdAt': '2026-09-22T10:15:30.000Z',
        'reportedTimeText': 'منذ 15 دقيقة',
        'status': 'Open',
        'statusLabel': 'قيد الانتظار',
        'boxCode': 'BOX-101',
        'area': 'حي النخيل',
        'affectedBoxesCount': 4,
        'affectedBoxesText': '4 صناديق',
        'priority': 'HIGH',
        'priorityText': 'عاجل',
        'priorityColor': '#EF4444',
        'driver': {
          'id': 'drv-1',
          'name': 'محمد علي',
          'code': 'DRV-100',
          'avatarUrl': 'https://cdn.example.com/avatar1.jpg',
          'phoneNumber': '0501234567',
          'isOnline': true,
          'status': 'online',
          'statusLabel': 'متصل',
          'subStatus': 'في الطريق للمطعم',
          'vehicleInfo': 'تويوتا كامري 2022',
          'rating': 4.9,
        },
        'description': 'السيارة توقفت تماماً بسبب ارتفاع حرارة المحرك',
        'evidencePhotos': [
          {
            'id': 'att-1',
            'url': 'https://cdn.example.com/photo_01.jpg',
            'thumbnailUrl': 'https://cdn.example.com/thumb_01.jpg',
            'uploadedAt': '2026-09-22T10:16:00.000Z',
            'orderNumber': 1,
          },
        ],
        'tripInfo': {
          'clientName': 'خالد السالم',
          'mealsCount': 3,
          'expectedDeliveryTime': '11:00 ص',
          'pickupLocation': 'مطعم البرجر',
          'dropoffLocation': 'شارع العليا العام',
          'orderId': 'ORD-555',
        },
        'resolution': null,
      };

      final dto = DispatcherIssueDetailsResponseDto.fromJson(json);
      expect(dto.driver, isNotNull);
      expect(dto.driver?.name, 'محمد علي');

      final entity = dto.toEntity();
      expect(entity.issueId, 'iss-001');
      expect(entity.title, 'عطل محرك السيارة');
      expect(entity.status, DispatcherIssueStatus.open);
      expect(entity.isResolved, isFalse);
      expect(entity.driver?.phoneNumber, '0501234567');
      expect(entity.evidencePhotos.length, 1);
      expect(entity.evidencePhotos.first.thumbnailUrl, contains('thumb_01'));
      expect(entity.tripInfo.clientName, 'خالد السالم');
      expect(entity.resolution, isNull);
    });

    test('Resolved issue JSON mapping with resolution object', () {
      final json = {
        'issueId': 'iss-002',
        'title': 'تأخر التوصيل',
        'status': 'Resolved',
        'statusLabel': 'تم الحل',
        'boxCode': 'BOX-102',
        'area': 'حي الروضة',
        'resolution': {
          'resolutionNotes': 'تم تسليم الطلب بنجاح بواسطة سائق بديل',
          'resolvedBy': 'المشرف عبدالعزيز',
          'resolvedAt': '2026-09-22T11:00:00.000Z',
          'resolvedAtText': '11:00 ص',
          'resolvedAction': 'REASSIGNED',
          'resolvedActionLabel': 'تم التعيين',
        },
      };

      final dto = DispatcherIssueDetailsResponseDto.fromJson(json);
      final entity = dto.toEntity();
      expect(entity.status, DispatcherIssueStatus.resolved);
      expect(entity.isResolved, isTrue);
      expect(entity.resolution, isNotNull);
      expect(entity.resolution?.resolutionNotes, contains('سائق بديل'));
      expect(entity.resolution?.resolvedBy, 'المشرف عبدالعزيز');
    });

    test('Candidates JSON mapping and empty candidates defensive behavior', () {
      final json = {
        'summary': {
          'issueId': 'iss-003',
          'title': 'عطل سيارة',
          'taskNumber': 'TASK-333',
          'area': 'الملز',
          'affectedBoxesCount': 2,
          'description': 'عطل بالمكابح',
        },
        'currentDriver': {
          'id': 'drv-orig',
          'name': 'سائق قديم',
          'code': 'DRV-001',
        },
        'candidates': [
          {
            'id': 'c-1',
            'name': 'عبدالله الشمري',
            'code': 'DRV-901',
            'avatarUrl': 'https://cdn.example.com/driver901.jpg',
            'isAvailable': true,
            'status': 'AVAILABLE',
            'statusText': 'متاح',
            'statusColorHex': '#10B981',
            'rating': 4.85,
            'activeOrdersCount': 0,
            'area': 'الملز',
            'isSameArea': true,
            'distanceKm': 2.3,
            'distanceText': '2.3 كم',
            'estimatedArrivalMinutes': 8,
            'estimatedArrivalText': '8 دقائق',
            'vehicleInfo': 'نيسان صني',
            'lastLocationUpdate': '2026-09-22T10:20:00.000Z',
            'lastLocationUpdateText': 'منذ دقيقة',
            'recommendationRank': 1,
          },
        ],
        'pagination': {
          'pageNumber': 1,
          'pageSize': 20,
          'totalCount': 1,
          'totalPages': 1,
          'hasNextPage': false,
          'hasPreviousPage': false,
        },
      };

      final dto = ReassignDriverCandidatesResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.summary.title, 'عطل سيارة');
      expect(entity.currentDriver?.name, 'سائق قديم');
      expect(entity.candidates.length, 1);
      expect(entity.candidates.first.recommendationRank, 1);
      expect(entity.candidates.first.isSameArea, isTrue);

      final emptyJson = <String, dynamic>{};
      final emptyCandidates = ReassignDriverCandidatesResponseDto.fromJson(emptyJson);
      expect(emptyCandidates.toEntity().candidates, isEmpty);
      expect(emptyCandidates.toEntity().currentDriver, isNull);
    });

    test('Reassignment and Resolve response DTOs mapping', () {
      final reassignmentJson = {
        'issueId': 'iss-004',
        'status': 'Resolved',
        'statusLabel': 'تم التعيين بنجاح',
        'reassignedDriver': {
          'id': 'drv-new',
          'name': 'سائق جديد',
          'code': 'DRV-999',
        },
        'message': 'تم تعيين السائق وتحديث الطلبات',
      };

      final reassignmentDto = ReassignmentResponseDto.fromJson(reassignmentJson);
      final reassignmentEntity = reassignmentDto.toEntity();
      expect(reassignmentEntity.status, DispatcherIssueStatus.resolved);
      expect(reassignmentEntity.reassignedDriver?.name, 'سائق جديد');
      expect(reassignmentEntity.message, contains('تم تعيين السائق'));

      final resolveJson = {
        'issueId': 'iss-005',
        'status': 'Resolved',
        'statusLabel': 'تم الحل',
        'resolution': {
          'resolutionNotes': 'تم التوصيل للعميل يدوياً',
        },
        'message': 'تم إغلاق البلاغ',
      };

      final resolveDto = ResolveIssueResponseDto.fromJson(resolveJson);
      final resolveEntity = resolveDto.toEntity();
      expect(resolveEntity.status, DispatcherIssueStatus.resolved);
      expect(resolveEntity.resolution?.resolutionNotes, 'تم التوصيل للعميل يدوياً');
    });

    test('Request DTO serialization and omission of null notes', () {
      const reqWithoutNotes = ReassignDriverRequestDto(
        replacementDriverId: 'driver-2',
        notes: null,
      );
      expect(reqWithoutNotes.toJson(), {'replacementDriverId': 'driver-2'});

      const reqWithNotes = ReassignDriverRequestDto(
        replacementDriverId: 'driver-2',
        notes: 'ملاحظة خاصة',
      );
      expect(reqWithNotes.toJson(), {
        'replacementDriverId': 'driver-2',
        'notes': 'ملاحظة خاصة',
      });

      const resolveReq = ResolveIssueRequestDto(
        resolutionNotes: 'ملاحظات حل البلاغ',
      );
      expect(resolveReq.toJson(), {
        'resolutionNotes': 'ملاحظات حل البلاغ',
      });
    });

    test('Defensive mapping with missing fields and unknown values', () {
      final partialDto = DispatcherIssueDetailsResponseDto.fromJson({
        'issueId': 'iss-unknown',
        'status': 'FutureCustomStatus',
      });
      final entity = partialDto.toEntity();
      expect(entity.issueId, 'iss-unknown');
      expect(entity.status, DispatcherIssueStatus.unknown);
      expect(entity.evidencePhotos, isEmpty);
      expect(entity.driver, isNull);
      expect(entity.resolution, isNull);
    });
  });
}
