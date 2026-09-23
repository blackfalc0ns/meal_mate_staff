import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/repo/box_tracking_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/get_box_tracking_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/report_box_issue_usecase.dart';

class _FakeBoxTrackingRepository implements BoxTrackingRepository {
  String? lastGetTrackingBoxId;
  String? lastReportIssueBoxId;
  ReportBoxIssueRequestEntity? lastReportIssueRequest;

  @override
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId) async {
    lastGetTrackingBoxId = boxId;
    return const ApiSuccessResult(
      data: BoxTrackingEntity(
        boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
        boxCode: '#BX-10256',
        status: BoxTrackingStatus.onTheWay,
        statusText: 'في الطريق',
        statusColor: '#3B82F6',
        customerName: 'أحمد',
        scheduledTimeText: '12:00 م',
        deliveryAddress: 'الرياض',
        programType: 'دايت',
        orderDateText: 'اليوم',
        customerNotes: 'ملاحظة',
        mealsSummary: '2 وجبات',
        steps: [],
      ),
    );
  }

  @override
  Future<ApiResult<ReportBoxIssueResultEntity>> reportIssue(
    String boxId,
    ReportBoxIssueRequestEntity request,
  ) async {
    lastReportIssueBoxId = boxId;
    lastReportIssueRequest = request;
    return const ApiSuccessResult(
      data: ReportBoxIssueResultEntity(
        issueId: 'iss-1',
        boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
        reportedAtUtc: null,
        message: 'تم',
      ),
    );
  }
}

void main() {
  late _FakeBoxTrackingRepository fakeRepo;
  late GetBoxTrackingUseCase getTrackingUseCase;
  late ReportBoxIssueUseCase reportIssueUseCase;

  const validGuid = '4f8a3c21-9b12-42e7-90c1-872f2316e110';

  setUp(() {
    fakeRepo = _FakeBoxTrackingRepository();
    getTrackingUseCase = GetBoxTrackingUseCase(fakeRepo);
    reportIssueUseCase = ReportBoxIssueUseCase(fakeRepo);
  });

  group('GetBoxTrackingUseCase', () {
    test(
      'locally rejects empty or invalid boxId without calling repository',
      () async {
        final emptyResult = await getTrackingUseCase('');
        expect(emptyResult, isA<ApiErrorResult>());
        expect(fakeRepo.lastGetTrackingBoxId, isNull);

        final invalidResult = await getTrackingUseCase('invalid-id');
        expect(invalidResult, isA<ApiErrorResult>());
        expect(fakeRepo.lastGetTrackingBoxId, isNull);
      },
    );

    test('calls repository with trimmed boxId when valid GUID', () async {
      final result = await getTrackingUseCase('  $validGuid  ');
      expect(result, isA<ApiSuccessResult>());
      expect(fakeRepo.lastGetTrackingBoxId, validGuid);
    });
  });

  group('ReportBoxIssueUseCase', () {
    test('locally rejects invalid boxId without calling repository', () async {
      const request = ReportBoxIssueRequestEntity(
        issueType: BoxIssueType.delayedDelivery,
        description: 'زحمة',
      );

      final result = await reportIssueUseCase('not-guid', request);
      expect(result, isA<ApiErrorResult>());
      expect(fakeRepo.lastReportIssueBoxId, isNull);
    });

    test(
      'locally rejects empty or blank description without calling repository',
      () async {
        const request = ReportBoxIssueRequestEntity(
          issueType: BoxIssueType.delayedDelivery,
          description: '   ',
        );

        final result = await reportIssueUseCase(validGuid, request);
        expect(result, isA<ApiErrorResult>());
        expect(fakeRepo.lastReportIssueBoxId, isNull);
      },
    );

    test(
      'calls repository with trimmed boxId and sanitized description',
      () async {
        const request = ReportBoxIssueRequestEntity(
          issueType: BoxIssueType.wrongAddress,
          description: '   العنوان غير دقيق   ',
        );

        final result = await reportIssueUseCase(' $validGuid ', request);
        expect(result, isA<ApiSuccessResult>());
        expect(fakeRepo.lastReportIssueBoxId, validGuid);
        expect(
          fakeRepo.lastReportIssueRequest?.description,
          'العنوان غير دقيق',
        );
        expect(
          fakeRepo.lastReportIssueRequest?.issueType,
          BoxIssueType.wrongAddress,
        );
      },
    );
  });
}
