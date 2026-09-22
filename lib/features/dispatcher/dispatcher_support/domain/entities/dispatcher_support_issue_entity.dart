import 'dispatcher_support_issue_type.dart';
import 'dispatcher_support_status.dart';

class DispatcherSupportIssueEntity {
  const DispatcherSupportIssueEntity({
    required this.id,
    required this.boxCode,
    this.title = '',
    this.issueCategory = '',
    this.categoryLabel,
    this.categoryColor,
    this.timeAgo = '',
    this.reportedAtUtc,
    this.driverId = '',
    this.driverCode = '',
    required this.driverName,
    this.driverAvatar = '',
    this.driverPhone = '',
    required this.area,
    this.vehicleInfo = '',
    this.vehicleModel = '',
    this.vehicleColor = '',
    this.priority = '',
    this.priorityLabel = '',
    this.priorityColor,
    this.status = DispatcherSupportStatus.open,
    this.statusLabel = '',
    this.issueType = DispatcherSupportIssueType.unknown,
    this.minutesAgo = 0,
    this.isDriverActive = true,
  });

  final String id;
  final String boxCode;
  final String title;
  final String issueCategory;
  final String? categoryLabel;
  final int? categoryColor;
  final String timeAgo;
  final DateTime? reportedAtUtc;
  final String driverId;
  final String driverCode;
  final String driverName;
  final String driverAvatar;
  final String driverPhone;
  final String area;
  final String vehicleInfo;
  final String vehicleModel;
  final String vehicleColor;
  final String priority;
  final String priorityLabel;
  final int? priorityColor;
  final DispatcherSupportStatus status;
  final String statusLabel;
  final DispatcherSupportIssueType issueType;
  final int minutesAgo;
  final bool isDriverActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherSupportIssueEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
