import 'driver_support_ticket_status.dart';
import 'driver_support_ticket_timeline_step.dart';

class DriverSupportTicketEntity {
  const DriverSupportTicketEntity({
    required this.id,
    required this.boxNumber,
    required this.title,
    required this.location,
    required this.updatedAt,
    required this.status,
    this.createdAt,
    this.boxIcon,
    this.issueDescription,
    this.attachedImages,
    this.orderNumber,
    this.orderTime,
    this.deliveryAddress,
    this.timelineSteps,
  });

  final String id;
  final String boxNumber;
  final String title;
  final String location;
  final String updatedAt;
  final DriverSupportTicketStatus status;
  final String? createdAt;
  final String? boxIcon;
  final String? issueDescription;
  final List<String>? attachedImages;
  final String? orderNumber;
  final String? orderTime;
  final String? deliveryAddress;
  final List<DriverSupportTicketTimelineStep>? timelineSteps;
}
