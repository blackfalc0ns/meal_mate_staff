sealed class DispatcherReassignmentEvent {
  const DispatcherReassignmentEvent();
}

class LoadReplacementCandidates extends DispatcherReassignmentEvent {
  const LoadReplacementCandidates();
}

class RetryReplacementCandidates extends DispatcherReassignmentEvent {
  const RetryReplacementCandidates();
}

class RefreshReplacementCandidates extends DispatcherReassignmentEvent {
  const RefreshReplacementCandidates();
}

class LoadNextReplacementCandidatesPage extends DispatcherReassignmentEvent {
  const LoadNextReplacementCandidatesPage();
}

class SelectReplacementDriver extends DispatcherReassignmentEvent {
  const SelectReplacementDriver(this.driverId);
  final String driverId;
}

class SubmitReplacementDriver extends DispatcherReassignmentEvent {
  const SubmitReplacementDriver({this.notes});
  final String? notes;
}

class ClearReassignmentFailure extends DispatcherReassignmentEvent {
  const ClearReassignmentFailure();
}
