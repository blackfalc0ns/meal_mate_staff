import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/data/mapper/dispatcher_notification_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/data/models/response/delivery_manager_notification_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/entities/dispatcher_notification_entity.dart';

void main() {
  group('DispatcherNotificationMapper', () {
    test('maps documented backend notification response correctly', () {
      final json = {
        'notificationId': '11111111-1111-4111-8111-111111111111',
        'type': 'driver-support-issue',
        'title': 'تحديث بلاغ دعم السائق',
        'body': 'تم تسجيل بلاغ دعم جديد للسائق.',
        'sentTimeAgo': 'منذ 2 دقيقة',
        'isRead': false,
        'section': 'support',
        'subjectId': '22222222-2222-4222-8222-222222222222',
        'deepLink':
            '/dispatcher/support/issues/22222222-2222-4222-8222-222222222222',
        'sentAtUtc': '2026-10-21T08:00:00Z',
      };

      final dto = DeliveryManagerNotificationResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.id, '11111111-1111-4111-8111-111111111111');
      expect(entity.type, DispatcherNotificationType.driverSupportIssue);
      expect(entity.rawType, 'driver-support-issue');
      expect(entity.title, 'تحديث بلاغ دعم السائق');
      expect(entity.description, 'تم تسجيل بلاغ دعم جديد للسائق.');
      expect(entity.timeAgo, 'منذ 2 دقيقة');
      expect(entity.isRead, isFalse);
      expect(entity.isUnread, isTrue);
      expect(entity.section, 'support');
      expect(entity.subjectId, '22222222-2222-4222-8222-222222222222');
      expect(
        entity.deepLink,
        '/dispatcher/support/issues/22222222-2222-4222-8222-222222222222',
      );
      expect(entity.sentAtUtc, DateTime.parse('2026-10-21T08:00:00Z'));
      expect(entity.iconAsset, AppAssets.notificationIconBoxDismiss);
    });

    test('maps driver-support-issue-resolved correctly', () {
      final json = {
        'notificationId': 'nid-resolved',
        'type': 'driver-support-issue-resolved',
        'title': 'تم حل البلاغ',
        'body': 'تم حل بلاغ دعم السائق بنجاح',
        'isRead': true,
      };

      final dto = DeliveryManagerNotificationResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.type, DispatcherNotificationType.driverSupportIssueResolved);
      expect(entity.isRead, isTrue);
      expect(entity.isUnread, isFalse);
      expect(entity.iconAsset, AppAssets.notificationIconBoxCheck);
    });

    test('maps driver-support-handover correctly', () {
      final json = {
        'notificationId': 'nid-handover',
        'type': 'driver-support-handover',
        'title': 'نقل عهدة',
        'body': 'مطلوب متابعة نقل عهدة',
      };

      final dto = DeliveryManagerNotificationResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.type, DispatcherNotificationType.driverSupportHandover);
      expect(entity.iconAsset, AppAssets.notificationIconBox);
    });

    test('maps unknown type without dropping item (section 8 requirement)', () {
      final json = {
        'notificationId': 'nid-unknown',
        'type': 'some-future-type',
        'title': 'إشعار مستقبلي',
        'body': 'نص إشعار لم يتم تصنيفه بعد',
      };

      final dto = DeliveryManagerNotificationResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.type, DispatcherNotificationType.other);
      expect(entity.rawType, 'some-future-type');
      expect(entity.title, 'إشعار مستقبلي');
      expect(entity.description, 'نص إشعار لم يتم تصنيفه بعد');
      expect(entity.iconAsset, AppAssets.notificationIconBox);
    });

    test('handles missing or null fields defensively', () {
      final dto = const DeliveryManagerNotificationResponseDto();
      final entity = dto.toEntity();

      expect(entity.id, isEmpty);
      expect(entity.type, DispatcherNotificationType.other);
      expect(entity.title, isNotEmpty);
      expect(entity.description, isEmpty);
      expect(entity.isRead, isFalse);
    });
  });
}
