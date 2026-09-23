import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/box_tracking_route_arguments.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_icon_kind.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_result_entity.dart';

void main() {
  group('BoxTrackingRouteArguments', () {
    test('validates non-empty GUID boxId', () {
      expect(const BoxTrackingRouteArguments(boxId: '').isValid, isFalse);
      expect(const BoxTrackingRouteArguments(boxId: '   ').isValid, isFalse);
      expect(
        const BoxTrackingRouteArguments(boxId: 'BX-10256').isValid,
        isFalse,
      );
      expect(
        const BoxTrackingRouteArguments(
          boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
        ).isValid,
        isTrue,
      );
    });
  });

  group('BoxTrackingStepStateX', () {
    test('parses documented API strings and unknown fallback', () {
      expect(
        BoxTrackingStepStateX.fromApi('Completed'),
        BoxTrackingStepState.completed,
      );
      expect(
        BoxTrackingStepStateX.fromApi('Active'),
        BoxTrackingStepState.active,
      );
      expect(
        BoxTrackingStepStateX.fromApi('Pending'),
        BoxTrackingStepState.pending,
      );
      expect(
        BoxTrackingStepStateX.fromApi('unexpected'),
        BoxTrackingStepState.pending,
      );
      expect(BoxTrackingStepStateX.fromApi(null), BoxTrackingStepState.pending);
    });
  });

  group('BoxTrackingStepIconKindX', () {
    test('parses documented API strings and unknown fallback', () {
      expect(
        BoxTrackingStepIconKindX.fromApi('Restaurant'),
        BoxTrackingStepIconKind.restaurant,
      );
      expect(
        BoxTrackingStepIconKindX.fromApi('Driver'),
        BoxTrackingStepIconKind.driver,
      );
      expect(
        BoxTrackingStepIconKindX.fromApi('Truck'),
        BoxTrackingStepIconKind.truck,
      );
      expect(
        BoxTrackingStepIconKindX.fromApi('Receipt'),
        BoxTrackingStepIconKind.receipt,
      );
      expect(
        BoxTrackingStepIconKindX.fromApi('unexpected'),
        BoxTrackingStepIconKind.unknown,
      );
      expect(
        BoxTrackingStepIconKindX.fromApi(null),
        BoxTrackingStepIconKind.unknown,
      );
    });
  });

  group('BoxIssueTypeX', () {
    test('parses documented issue types and serializes correctly', () {
      expect(BoxIssueTypeX.fromApi('DamagedBox'), BoxIssueType.damagedBox);
      expect(
        BoxIssueTypeX.fromApi('DelayedDelivery'),
        BoxIssueType.delayedDelivery,
      );
      expect(BoxIssueTypeX.fromApi('WrongAddress'), BoxIssueType.wrongAddress);
      expect(
        BoxIssueTypeX.fromApi('CustomerUnreachable'),
        BoxIssueType.customerUnreachable,
      );
      expect(BoxIssueTypeX.fromApi('Other'), BoxIssueType.other);
      expect(BoxIssueTypeX.fromApi('UnknownVal'), BoxIssueType.other);

      expect(BoxIssueType.damagedBox.toApi(), 'DamagedBox');
      expect(BoxIssueType.delayedDelivery.toApi(), 'DelayedDelivery');
      expect(BoxIssueType.wrongAddress.toApi(), 'WrongAddress');
      expect(BoxIssueType.customerUnreachable.toApi(), 'CustomerUnreachable');
      expect(BoxIssueType.other.toApi(), 'Other');
    });
  });

  group('BoxTrackingStatusX', () {
    test('parses status values and fallback', () {
      expect(
        BoxTrackingStatusX.fromApi('ReadyAtRestaurant'),
        BoxTrackingStatus.readyAtRestaurant,
      );
      expect(
        BoxTrackingStatusX.fromApi('PickedUpByDriver'),
        BoxTrackingStatus.pickedUpByDriver,
      );
      expect(
        BoxTrackingStatusX.fromApi('OnTheWay'),
        BoxTrackingStatus.onTheWay,
      );
      expect(
        BoxTrackingStatusX.fromApi('InDelivery'),
        BoxTrackingStatus.onTheWay,
      );
      expect(
        BoxTrackingStatusX.fromApi('Delivered'),
        BoxTrackingStatus.delivered,
      );
      expect(BoxTrackingStatusX.fromApi('Pending'), BoxTrackingStatus.pending);
      expect(
        BoxTrackingStatusX.fromApi('Cancelled'),
        BoxTrackingStatus.cancelled,
      );
      expect(BoxTrackingStatusX.fromApi('Unknown'), BoxTrackingStatus.unknown);
      expect(BoxTrackingStatusX.fromApi(null), BoxTrackingStatus.unknown);
    });
  });

  group('BoxTrackingDriverEntity', () {
    test('holds separate ID, code, name, phone, and optional avatar', () {
      const driver = BoxTrackingDriverEntity(
        driverId: 'drv-uuid-1',
        driverCode: 'DR-1025',
        fullName: 'أحمد السعيد',
        phoneNumber: '+966551234567',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(driver.driverId, 'drv-uuid-1');
      expect(driver.driverCode, 'DR-1025');
      expect(driver.fullName, 'أحمد السعيد');
      expect(driver.phoneNumber, '+966551234567');
      expect(driver.avatarUrl, 'https://example.com/avatar.jpg');
      // Compatibility
      expect(driver.id, 'drv-uuid-1');
      expect(driver.name, 'أحمد السعيد');
      expect(driver.phone, '+966551234567');
    });
  });

  group('BoxTrackingStepEntity', () {
    test(
      'holds step index, title, description, time, state, and iconKind without Flutter IconData',
      () {
        const step = BoxTrackingStepEntity(
          step: 1,
          title: 'جاهز في المطعم',
          description: 'تم تجهيز الطلب',
          time: '10:00 ص',
          state: BoxTrackingStepState.completed,
          iconKind: BoxTrackingStepIconKind.restaurant,
        );

        expect(step.step, 1);
        expect(step.title, 'جاهز في المطعم');
        expect(step.description, 'تم تجهيز الطلب');
        expect(step.time, '10:00 ص');
        expect(step.state, BoxTrackingStepState.completed);
        expect(step.iconKind, BoxTrackingStepIconKind.restaurant);
        expect(step.isCompleted, isTrue);
        expect(step.isActive, isFalse);
      },
    );
  });

  group('BoxTrackingEntity', () {
    test('holds all backend fields and nullable driver', () {
      const tracking = BoxTrackingEntity(
        boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
        boxCode: '#BX-10256',
        status: BoxTrackingStatus.onTheWay,
        statusText: 'في الطريق',
        statusColor: '#3B82F6',
        customerName: 'أحمد العتيبي',
        scheduledTimeText: '12:30 م',
        deliveryAddress: 'السليمانية، الرياض',
        driver: null,
        programType: 'دايت متوازن',
        orderDateText: 'اليوم 09:50 ص',
        customerNotes: 'يرجى الاتصال قبل الوصول',
        mealsSummary: '3 وجبات (يوم كامل)',
        steps: [],
      );

      expect(tracking.boxId, '4f8a3c21-9b12-42e7-90c1-872f2316e110');
      expect(tracking.boxCode, '#BX-10256');
      expect(tracking.status, BoxTrackingStatus.onTheWay);
      expect(tracking.driver, isNull);
      expect(tracking.deliveryTime, '12:30 م');
      expect(tracking.planType, 'دايت متوازن');
      expect(tracking.orderDate, 'اليوم 09:50 ص');
      expect(tracking.mealCount, '3 وجبات (يوم كامل)');
    });
  });

  group('ReportBoxIssueRequestEntity and ResultEntity', () {
    test('holds issue request and result properties', () {
      const request = ReportBoxIssueRequestEntity(
        issueType: BoxIssueType.delayedDelivery,
        description: 'تأخير بسبب الازدحام',
      );

      expect(request.issueType, BoxIssueType.delayedDelivery);
      expect(request.description, 'تأخير بسبب الازدحام');
      expect(request.severity, 'Medium');

      final result = ReportBoxIssueResultEntity(
        issueId: 'issue-123',
        boxId: 'box-123',
        reportedAtUtc: DateTime.utc(2026, 9, 23, 12, 0),
        message: 'تم تسجيل البلاغ بنجاح',
      );

      expect(result.issueId, 'issue-123');
      expect(result.boxId, 'box-123');
      expect(result.reportedAtUtc, DateTime.utc(2026, 9, 23, 12, 0));
      expect(result.message, 'تم تسجيل البلاغ بنجاح');
    });
  });
}
