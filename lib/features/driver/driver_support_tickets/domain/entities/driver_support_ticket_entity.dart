import 'driver_support_ticket_status.dart';

class DriverSupportTicketEntity {
  const DriverSupportTicketEntity({
    required this.id,
    required this.boxNumber,
    required this.title,
    required this.location,
    required this.updatedAt,
    required this.status,
  });

  final String id;
  final String boxNumber;
  final String title;
  final String location;
  final String updatedAt;
  final DriverSupportTicketStatus status;
}
