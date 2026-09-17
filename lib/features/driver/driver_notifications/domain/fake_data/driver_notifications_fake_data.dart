import '../entities/driver_notification_entity.dart';
import '../entities/driver_notification_filter_type.dart';
import '../entities/driver_notification_type.dart';

class DriverNotificationsFakeData {
  const DriverNotificationsFakeData._();

  static const List<DriverNotificationEntity> defaultNotifications = [
    DriverNotificationEntity(
      id: '1',
      title: 'طلب جديد',
      body: 'لديك طلب توصيل جديد رقم 1258',
      time: 'الآن',
      type: DriverNotificationType.newOrder,
      filterCategory: DriverNotificationFilterType.deliveryOrders,
      isRead: false,
      isToday: true,
    ),
    DriverNotificationEntity(
      id: '2',
      title: 'تم تسليم الطلب',
      body: 'تم تسليم الطلب #1257 بنجاح',
      time: '10:50 ص',
      type: DriverNotificationType.delivered,
      filterCategory: DriverNotificationFilterType.deliveryOrders,
      isRead: true,
      isToday: true,
    ),
    DriverNotificationEntity(
      id: '3',
      title: 'عائدات اليوم',
      body: 'تم إضافة 23.750 د.ك إلى رصيدك',
      time: '9:15 ص',
      type: DriverNotificationType.earnings,
      filterCategory: DriverNotificationFilterType.system,
      isRead: true,
      isToday: true,
    ),
    DriverNotificationEntity(
      id: '4',
      title: 'تقييم جديد',
      body: 'حصلت على تقييم 5 نجوم من العملاء',
      time: 'أمس 8:45 م',
      type: DriverNotificationType.rating,
      filterCategory: DriverNotificationFilterType.system,
      isRead: true,
      isToday: false,
    ),
    DriverNotificationEntity(
      id: '5',
      title: 'عرض جديد',
      body: 'حقق 10 توصيلات إضافية واحصل على مكافأة',
      time: 'أمس 6:20 م',
      type: DriverNotificationType.offer,
      filterCategory: DriverNotificationFilterType.offers,
      isRead: true,
      isToday: false,
    ),
    DriverNotificationEntity(
      id: '6',
      title: 'تنبيه',
      body: 'يرجى تحديث بياناتك البنكية',
      time: 'أمس 4:20 م',
      type: DriverNotificationType.system,
      filterCategory: DriverNotificationFilterType.system,
      isRead: true,
      isToday: false,
    ),
  ];
}
