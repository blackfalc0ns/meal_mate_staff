import '../../../domain/entities/reassignment_result_entity.dart';

sealed class DispatcherIssueDetailsEvent {
  const DispatcherIssueDetailsEvent();
}

class LoadIssueDetails extends DispatcherIssueDetailsEvent {
  const LoadIssueDetails();
}

class RetryIssueDetails extends DispatcherIssueDetailsEvent {
  const RetryIssueDetails();
}

class SubmitIssueResolution extends DispatcherIssueDetailsEvent {
  const SubmitIssueResolution(this.notes);
  final String notes;
}

class ClearIssueResolutionFailure extends DispatcherIssueDetailsEvent {
  const ClearIssueResolutionFailure();
}

class ApplyReassignmentResult extends DispatcherIssueDetailsEvent {
  const ApplyReassignmentResult(this.result);
  final ReassignmentResultEntity result;
}
