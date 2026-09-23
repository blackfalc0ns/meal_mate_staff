import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/mapper/box_tracking_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/models/response/box_tracking_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/models/response/report_box_issue_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_icon_kind.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';

void main() {
  group('BoxTrackingResponseDto and mapper', () {
    test('maps full valid JSON payload correctly', () {
      final payload = {
        'box': {
          'boxId': '4f8a3c21-9b12-42e7-90c1-872f2316e110',
          'boxCode': '#BX-10256',
          'status': 'OnTheWay',
          'statusText': 'في الطريق',
          'statusColor': '#3B82F6',
          'customerName': 'أحمد العتيبي',
          'scheduledTimeText': '12:30 م',
          'deliveryAddress': 'السليمانية، الرياض',
        },
        'driver': {
          'driverId': 'drv-uuid-1',
          'driverCode': 'DR-1025',
          'fullName': 'أحمد السعيد',
          'phoneNumber': '+966501234567',
          'avatarUrl': 'https://example.com/avatar.jpg',
        },
        'details': {
          'programType': 'دايت متوازن',
          'orderDateText': 'اليوم 09:50 ص',
          'customerNotes': 'يرجى الاتصال قبل الوصول',
          'mealsSummary': '3 وجبات (يوم كامل)',
        },
        'timeline': [
          {
            'step': 2,
            'title': 'استلمه السائق',
            'description': 'أحمد السعيد استلم البوكس',
            'time': 'اليوم 10:28 ص',
            'state': 'Completed',
            'icon': 'Driver',
          },
          {
            'step': 1,
            'title': 'جاهز في المطعم',
            'description': 'تم تجهيز البوكس وجاهز للاستلام',
            'time': 'اليوم 10:15 ص',
            'state': 'Completed',
            'icon': 'Restaurant',
          },
          {
            'step': 3,
            'title': 'في الطريق للتوصيل',
            'description': 'البوكس في طريقه إلى العميل',
            'time': 'اليوم 10:45 ص',
            'state': 'Active',
            'icon': 'Truck',
          },
          {
            'step': 4,
            'title': 'تم التسليم',
            'description': null,
            'time': null,
            'state': 'Pending',
            'icon': 'Receipt',
          },
        ],
      };

      final dto = BoxTrackingResponseDto.fromJson(payload);
      final entity = dto.toEntity();

      expect(entity.boxId, '4f8a3c21-9b12-42e7-90c1-872f2316e110');
      expect(entity.boxCode, '#BX-10256');
      expect(entity.status, BoxTrackingStatus.onTheWay);
      expect(entity.statusText, 'في الطريق');
      expect(entity.statusColor, '#3B82F6');
      expect(entity.customerName, 'أحمد العتيبي');
      expect(entity.scheduledTimeText, '12:30 م');
      expect(entity.deliveryAddress, 'السليمانية، الرياض');

      expect(entity.driver?.driverId, 'drv-uuid-1');
      expect(entity.driver?.driverCode, 'DR-1025');
      expect(entity.driver?.fullName, 'أحمد السعيد');
      expect(entity.driver?.phoneNumber, '+966501234567');
      expect(entity.driver?.avatarUrl, 'https://example.com/avatar.jpg');

      expect(entity.programType, 'دايت متوازن');
      expect(entity.orderDateText, 'اليوم 09:50 ص');
      expect(entity.customerNotes, 'يرجى الاتصال قبل الوصول');
      expect(entity.mealsSummary, '3 وجبات (يوم كامل)');

      // Timeline must be sorted by step ascending (1, 2, 3, 4)
      expect(entity.steps.map((s) => s.step), orderedEquals([1, 2, 3, 4]));
      expect(entity.steps.first.iconKind, BoxTrackingStepIconKind.restaurant);
      expect(entity.steps.first.state, BoxTrackingStepState.completed);
      expect(entity.steps[2].iconKind, BoxTrackingStepIconKind.truck);
      expect(entity.steps[2].state, BoxTrackingStepState.active);
      expect(entity.steps[3].time, isNull);
    });

    test('handles empty / null nested JSON safely without throwing', () {
      final dto = BoxTrackingResponseDto.fromJson(const {});
      final entity = dto.toEntity();

      expect(entity.boxId, isEmpty);
      expect(entity.boxCode, isEmpty);
      expect(entity.status, BoxTrackingStatus.unknown);
      expect(entity.driver, isNull);
      expect(entity.steps, isEmpty);
    });
  });

  group('ReportBoxIssueRequestEntity to DTO mapping', () {
    test('serializes toDto() with correct json keys and documented values', () {
      const entity = ReportBoxIssueRequestEntity(
        issueType: BoxIssueType.delayedDelivery,
        description: 'Traffic delay',
        severity: 'Medium',
      );

      final dto = entity.toDto();
      final json = dto.toJson();

      expect(json['issueType'], 'DelayedDelivery');
      expect(json['description'], 'Traffic delay');
      expect(json['severity'], 'Medium');
    });
  });

  group('ReportBoxIssueResponseDto and mapper', () {
    test('maps report issue response to domain result entity', () {
      final json = {
        'issueId': 'iss-999',
        'boxId': '4f8a3c21-9b12-42e7-90c1-872f2316e110',
        'reportedAtUtc': '2026-09-23T12:30:00Z',
        'message': 'تم تسجيل البلاغ بنجاح',
      };

      final dto = ReportBoxIssueResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.issueId, 'iss-999');
      expect(entity.boxId, '4f8a3c21-9b12-42e7-90c1-872f2316e110');
      expect(entity.reportedAtUtc, DateTime.parse('2026-09-23T12:30:00Z'));
      expect(entity.message, 'تم تسجيل البلاغ بنجاح');
    });

    test('handles nulls in report issue response gracefully', () {
      final dto = ReportBoxIssueResponseDto.fromJson(const {});
      final entity = dto.toEntity();

      expect(entity.issueId, isEmpty);
      expect(entity.boxId, isEmpty);
      expect(entity.reportedAtUtc, isNull);
      expect(entity.message, isEmpty);
    });
  });
}
