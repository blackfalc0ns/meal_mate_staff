import 'dispatcher_support_issue_type.dart';
import 'dispatcher_support_status.dart';

class DispatcherSupportIssueEntity {
  const DispatcherSupportIssueEntity({
    required this.id,
    required this.boxCode,
    required this.driverName,
    required this.driverAvatar,
    required this.driverPhone,
    required this.area,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.issueType,
    required this.status,
    required this.minutesAgo,
    this.isDriverActive = true,
  });

  final String id;
  final String boxCode;
  final String driverName;
  final String driverAvatar;
  final String driverPhone;
  final String area;
  final String vehicleModel;
  final String vehicleColor;
  final DispatcherSupportIssueType issueType;
  final DispatcherSupportStatus status;
  final int minutesAgo;
  final bool isDriverActive;
}
