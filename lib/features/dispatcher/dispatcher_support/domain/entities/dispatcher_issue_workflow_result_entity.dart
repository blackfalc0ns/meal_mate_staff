class DispatcherIssueWorkflowResultEntity {
  const DispatcherIssueWorkflowResultEntity({
    required this.changed,
    required this.requiresRefresh,
    this.issueId,
  });

  final bool changed;
  final bool requiresRefresh;
  final String? issueId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherIssueWorkflowResultEntity &&
          runtimeType == other.runtimeType &&
          changed == other.changed &&
          requiresRefresh == other.requiresRefresh &&
          issueId == other.issueId;

  @override
  int get hashCode => Object.hash(changed, requiresRefresh, issueId);
}
