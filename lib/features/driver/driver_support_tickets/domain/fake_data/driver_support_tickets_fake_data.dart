import '../entities/driver_support_ticket_entity.dart';
import '../entities/driver_support_ticket_status.dart';

class DriverSupportTicketsFakeData {
  const DriverSupportTicketsFakeData._();

  static const List<DriverSupportTicketEntity> tickets = [
    DriverSupportTicketEntity(
      id: '1',
      boxNumber: '#BX-1256',
      title: 'العميل غير متواجد',
      location: 'منطقة السالمية',
      updatedAt: 'آخر تحديث منذ 20 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    ),
    DriverSupportTicketEntity(
      id: '2',
      boxNumber: '#BX-1257',
      title: 'العنوان غير واضح',
      location: 'منطقة حولي',
      updatedAt: 'آخر تحديث منذ 45 دقيقة',
      status: DriverSupportTicketStatus.awaitingResponse,
    ),
    DriverSupportTicketEntity(
      id: '3',
      boxNumber: '#BX-1258',
      title: 'تأخير في الوصول',
      location: 'منطقة الفحيحيل',
      updatedAt: 'آخر تحديث منذ ساعة',
      status: DriverSupportTicketStatus.resolved,
    ),
    DriverSupportTicketEntity(
      id: '4',
      boxNumber: '#BX-1259',
      title: 'إعادة جدولة موعد التسليم',
      location: 'منطقة الشويخ',
      updatedAt: 'آخر تحديث منذ ساعتين',
      status: DriverSupportTicketStatus.resolved,
    ),
    DriverSupportTicketEntity(
      id: '5',
      boxNumber: '#BX-1260',
      title: 'تلف في محتويات الطلب',
      location: 'منطقة اليرموك',
      updatedAt: 'آخر تحديث منذ 15 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    ),
    DriverSupportTicketEntity(
      id: '6',
      boxNumber: '#BX-1261',
      title: 'تم استلام الطلب مسبقاً',
      location: 'منطقة العديلية',
      updatedAt: 'آخر تحديث منذ 3 ساعات',
      status: DriverSupportTicketStatus.resolved,
    ),
  ];

  static int get totalCount => tickets.length;
  static int get underReviewCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.underReview).length;
  static int get awaitingResponseCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.awaitingResponse).length;
  static int get resolvedCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.resolved).length;
}
