import '../../domain/entities/box_issue_type.dart';

sealed class BoxTrackingEvent {
  const BoxTrackingEvent();
}

final class LoadBoxTrackingEvent extends BoxTrackingEvent {
  const LoadBoxTrackingEvent();
}

final class RetryBoxTrackingEvent extends BoxTrackingEvent {
  const RetryBoxTrackingEvent();
}

final class RefreshBoxTrackingEvent extends BoxTrackingEvent {
  const RefreshBoxTrackingEvent();
}

final class ChangeBoxIssueTypeEvent extends BoxTrackingEvent {
  const ChangeBoxIssueTypeEvent(this.issueType);
  final BoxIssueType issueType;
}

final class ChangeBoxIssueDescriptionEvent extends BoxTrackingEvent {
  const ChangeBoxIssueDescriptionEvent(this.description);
  final String description;
}

final class SubmitBoxIssueEvent extends BoxTrackingEvent {
  const SubmitBoxIssueEvent();
}

final class ResetBoxIssueFormEvent extends BoxTrackingEvent {
  const ResetBoxIssueFormEvent();
}
