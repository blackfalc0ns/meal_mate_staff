sealed class AssignBoxEvent {
  const AssignBoxEvent();
}

class LoadAssignBoxEvent extends AssignBoxEvent {
  const LoadAssignBoxEvent();
}

class RetryAssignBoxDetailsEvent extends AssignBoxEvent {
  const RetryAssignBoxDetailsEvent();
}

class RefreshAssignBoxDetailsEvent extends AssignBoxEvent {
  const RefreshAssignBoxDetailsEvent();
}

class SelectAssignBoxDriverEvent extends AssignBoxEvent {
  const SelectAssignBoxDriverEvent(this.driverId);
  final String driverId;
}

class LoadAssignBoxSummaryEvent extends AssignBoxEvent {
  const LoadAssignBoxSummaryEvent();
}

class RetryAssignBoxSummaryEvent extends AssignBoxEvent {
  const RetryAssignBoxSummaryEvent();
}

class SubmitAssignBoxEvent extends AssignBoxEvent {
  const SubmitAssignBoxEvent({required this.localizedNotes});
  final String localizedNotes;
}

class ClearAssignBoxNoticeEvent extends AssignBoxEvent {
  const ClearAssignBoxNoticeEvent();
}
