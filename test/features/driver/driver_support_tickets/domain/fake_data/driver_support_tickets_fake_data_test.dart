import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data.dart';

void main() {
  test('DriverSupportTicketsFakeData contains exactly 6 tickets matching Figma counts', () {
    expect(DriverSupportTicketsFakeData.tickets.length, 6);
    expect(DriverSupportTicketsFakeData.totalCount, 6);
    expect(DriverSupportTicketsFakeData.underReviewCount, 2);
    expect(DriverSupportTicketsFakeData.awaitingResponseCount, 1);
    expect(DriverSupportTicketsFakeData.resolvedCount, 3);

    for (final ticket in DriverSupportTicketsFakeData.tickets) {
      expect(ticket.id.isNotEmpty, isTrue);
      expect(ticket.boxNumber.startsWith('#BX-'), isTrue);
      expect(ticket.title.isNotEmpty, isTrue);
      expect(ticket.location.isNotEmpty, isTrue);
      expect(ticket.updatedAt.isNotEmpty, isTrue);
    }
  });
}
