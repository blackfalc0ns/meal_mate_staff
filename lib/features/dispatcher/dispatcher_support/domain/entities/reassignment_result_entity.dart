import 'dispatcher_issue_driver_entity.dart';
import 'dispatcher_issue_resolution_entity.dart';
import 'dispatcher_issue_status.dart';

class ReassignmentResultEntity {
  const ReassignmentResultEntity({
    required this.issueId,
    this.status = DispatcherIssueStatus.resolved,
    this.statusLabel = '',
    this.reassignedDriver,
    this.message,
    this.resolution,
  });

  final String issueId;
  final DispatcherIssueStatus status;
  final String statusLabel;
  final DispatcherIssueDriverEntity? reassignedDriver;
  final String? message;
  final DispatcherIssueResolutionEntity? resolution;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReassignmentResultEntity &&
          runtimeType == other.runtimeType &&
          issueId == other.issueId &&
          status == other.status &&
          reassignedDriver == other.reassignedDriver;

  @override
  int get hashCode => Object.hash(issueId, status, reassignedDriver);
}
