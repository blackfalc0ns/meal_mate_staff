import 'dispatcher_issue_resolution_entity.dart';
import 'dispatcher_issue_status.dart';

class ResolveIssueResultEntity {
  const ResolveIssueResultEntity({
    required this.issueId,
    this.status = DispatcherIssueStatus.resolved,
    this.statusLabel = '',
    this.resolution,
    this.message,
  });

  final String issueId;
  final DispatcherIssueStatus status;
  final String statusLabel;
  final DispatcherIssueResolutionEntity? resolution;
  final String? message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolveIssueResultEntity &&
          runtimeType == other.runtimeType &&
          issueId == other.issueId &&
          status == other.status &&
          resolution == other.resolution;

  @override
  int get hashCode => Object.hash(issueId, status, resolution);
}
