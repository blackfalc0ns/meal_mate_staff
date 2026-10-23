import 'driver_support_ticket_status.dart';
import 'driver_support_ticket_timeline_step.dart';

class DriverSupportTicketDetailsEntity {
  const DriverSupportTicketDetailsEntity({
    required this.issueId,
    required this.category,
    required this.categoryLabel,
    required this.title,
    this.description,
    required this.status,
    required this.rawStatus,
    required this.statusLabel,
    this.submittedAtUtc,
    this.updatedAtUtc,
    this.orderCode,
    this.address,
    this.area,
    this.orderCreatedAtUtc,
    this.timeline = const [],
    this.evidenceUrls = const [],
    this.resolutionNotes,
    this.resolvedAtUtc,
    this.canContactSupport = false,
    this.contactChannel,
  });

  final String issueId;
  final String category;
  final String categoryLabel;
  final String title;
  final String? description;
  final DriverSupportTicketStatus status;
  final String rawStatus;
  final String statusLabel;
  final DateTime? submittedAtUtc;
  final DateTime? updatedAtUtc;
  final String? orderCode;
  final String? address;
  final String? area;
  final DateTime? orderCreatedAtUtc;
  final List<DriverSupportTicketTimelineStep> timeline;
  final List<String> evidenceUrls;
  final String? resolutionNotes;
  final DateTime? resolvedAtUtc;
  final bool canContactSupport;
  final String? contactChannel;

  bool get isTerminal => status == DriverSupportTicketStatus.resolved;
  bool get canAddPhotos => !isTerminal && evidenceUrls.length < 3;
}
