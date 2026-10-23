import 'driver_support_ticket_status.dart';

class DriverSupportAddPhotosResultEntity {
  const DriverSupportAddPhotosResultEntity({
    required this.issueId,
    required this.status,
    required this.statusLabel,
    required this.evidenceUrls,
  });

  final String issueId;
  final DriverSupportTicketStatus status;
  final String statusLabel;
  final List<String> evidenceUrls;
}
