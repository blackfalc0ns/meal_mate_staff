import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';

void main() {
  test('DriverSupportTicketEntity stores correct properties', () {
    const ticket = DriverSupportTicketEntity(
      id: '1',
      boxNumber: '#BX-1256',
      title: 'العميل غير متواجد',
      location: 'منطقة السالمية',
      updatedAt: 'آخر تحديث منذ 20 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    );

    expect(ticket.id, '1');
    expect(ticket.boxNumber, '#BX-1256');
    expect(ticket.title, 'العميل غير متواجد');
    expect(ticket.location, 'منطقة السالمية');
    expect(ticket.updatedAt, 'آخر تحديث منذ 20 دقيقة');
    expect(ticket.status, DriverSupportTicketStatus.underReview);
  });
}
