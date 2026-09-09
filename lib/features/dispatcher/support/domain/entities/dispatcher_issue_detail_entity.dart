import 'dispatcher_issue_attachment_entity.dart';

class DispatcherIssueDetailEntity {
  const DispatcherIssueDetailEntity({
    required this.id,
    required this.title,
    required this.minutesAgo,
    required this.isUrgent,
    required this.taskNumber,
    required this.area,
    required this.affectedBoxesCount,
    required this.priority,
    required this.driverName,
    required this.driverCode,
    required this.driverAvatar,
    required this.isDriverOnline,
    required this.driverSubStatus,
    required this.description,
    required this.attachments,
    required this.clientName,
    required this.mealsCount,
    required this.expectedDeliveryTime,
    required this.pickupLocation,
    required this.dropoffLocation,
  });

  final String id;
  final String title;
  final int minutesAgo;
  final bool isUrgent;
  final String taskNumber;
  final String area;
  final int affectedBoxesCount;
  final String priority;
  final String driverName;
  final String driverCode;
  final String driverAvatar;
  final bool isDriverOnline;
  final String driverSubStatus;
  final String description;
  final List<DispatcherIssueAttachmentEntity> attachments;
  final String clientName;
  final int mealsCount;
  final String expectedDeliveryTime;
  final String pickupLocation;
  final String dropoffLocation;
}
