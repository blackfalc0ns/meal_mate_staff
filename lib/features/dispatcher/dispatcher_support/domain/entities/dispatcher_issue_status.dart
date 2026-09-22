enum DispatcherIssueStatus {
  open,
  inProgress,
  resolved,
  unknown;
}

extension DispatcherIssueStatusX on DispatcherIssueStatus {
  static DispatcherIssueStatus fromApi(String? value) {
    if (value == null) return DispatcherIssueStatus.unknown;
    final normalized = value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'open':
        return DispatcherIssueStatus.open;
      case 'inprogress':
      case 'in_progress':
        return DispatcherIssueStatus.inProgress;
      case 'resolved':
      case 'closed':
        return DispatcherIssueStatus.resolved;
      default:
        return DispatcherIssueStatus.unknown;
    }
  }

  bool get isResolved => this == DispatcherIssueStatus.resolved;
  bool get isOpen => this == DispatcherIssueStatus.open;
  bool get isInProgress => this == DispatcherIssueStatus.inProgress;
}
