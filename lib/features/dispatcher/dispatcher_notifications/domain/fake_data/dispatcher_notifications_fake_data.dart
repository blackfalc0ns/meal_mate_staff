import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_notification_entity.dart';

class DispatcherNotificationsFakeData {
  const DispatcherNotificationsFakeData._();

  static const int allCount = 12;
  static const int unreadCount = 5;

  static const List<DispatcherNotificationEntity> notifications = [
    DispatcherNotificationEntity(
      id: 'NOTIF-1',
      type: DispatcherNotificationType.newBox,
      title: 'بوكس جديد جاهز للاستلام',
      description:
          'هناك 3 بوكسات جديدة جاهزة للاستلام من مطعم "المذاق اللبناني-المهندسين"',
      timeAgo: 'منذ 2 دقيقة',
      iconAsset: AppAssets.notificationIconBox,
      isUnread: true,
    ),
    DispatcherNotificationEntity(
      id: 'NOTIF-2',
      type: DispatcherNotificationType.boxProblem,
      title: 'مشكلة في بوكس',
      description: 'تم الإبلاغ عن تلف في بوكس BX-1260 من السائق محمد العازمي',
      timeAgo: 'منذ 5 دقيقة',
      iconAsset: AppAssets.notificationIconBoxDismiss,
      isUnread: true,
    ),
    DispatcherNotificationEntity(
      id: 'NOTIF-3',
      type: DispatcherNotificationType.driverCompleted,
      title: 'السائق أحمد أكمل كل بوكساته',
      description:
          'السائق أحمد حسن أكمل استلام جميع البوكسات (5 بوكسات) بنجاح',
      timeAgo: 'منذ 12 دقيقة',
      iconAsset: AppAssets.notificationIconUser,
      isUnread: true,
    ),
    DispatcherNotificationEntity(
      id: 'NOTIF-4',
      type: DispatcherNotificationType.replacementBox,
      title: 'تم استلام بوكس بديل',
      description:
          'تم استلام البوكس البديل للبوكس BX-1260 من مطعم المذاق اللبناني',
      timeAgo: 'منذ 25 دقيقة',
      iconAsset: AppAssets.notificationIconBoxCheck,
      isUnread: false,
    ),
    DispatcherNotificationEntity(
      id: 'NOTIF-5',
      type: DispatcherNotificationType.performanceAlert,
      title: 'تنبيه أداء',
      description: 'انخفص متوسط وقت الاستلام اليوم لمستوى أقل من الهدف المحدد',
      timeAgo: 'منذ 1 ساعة',
      iconAsset: AppAssets.notificationIconHierarchy,
      isUnread: false,
    ),
    DispatcherNotificationEntity(
      id: 'NOTIF-6',
      type: DispatcherNotificationType.tripUpdate,
      title: 'تحديث على الرحلة',
      description: 'تم تحديث موقع استلام جديد للرحلة DR-2011',
      timeAgo: 'منذ 2 ساعة',
      iconAsset: AppAssets.notificationIconMapMarker,
      isUnread: false,
    ),
    DispatcherNotificationEntity(
      id: 'NOTIF-7',
      type: DispatcherNotificationType.delayedBox,
      title: 'بوكس متأخر',
      description: 'البوكس BX-1255 متأخر عن وقت الاستلام المحدد',
      timeAgo: 'منذ 3 ساعة',
      iconAsset: AppAssets.notificationIconClock,
      isUnread: false,
    ),
  ];
}
