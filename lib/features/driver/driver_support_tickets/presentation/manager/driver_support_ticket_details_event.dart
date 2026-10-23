import 'dart:io';

sealed class DriverSupportTicketDetailsEvent {
  const DriverSupportTicketDetailsEvent();
}

class LoadDriverSupportTicketDetailsEvent
    extends DriverSupportTicketDetailsEvent {
  const LoadDriverSupportTicketDetailsEvent(this.issueId);
  final String issueId;
}

class RefreshDriverSupportTicketDetailsEvent
    extends DriverSupportTicketDetailsEvent {
  const RefreshDriverSupportTicketDetailsEvent();
}

class AddDriverSupportTicketPhotoEvent extends DriverSupportTicketDetailsEvent {
  const AddDriverSupportTicketPhotoEvent(this.file);
  final File file;
}

class RetryAttachPhotosEvent extends DriverSupportTicketDetailsEvent {
  const RetryAttachPhotosEvent();
}

class RetryDriverSupportTicketDetailsEvent
    extends DriverSupportTicketDetailsEvent {
  const RetryDriverSupportTicketDetailsEvent();
}

class OnRealtimeDetailsUpdatedEvent extends DriverSupportTicketDetailsEvent {
  const OnRealtimeDetailsUpdatedEvent({this.issueId});
  final String? issueId;
}

class ClearDetailsFeedbackEvent extends DriverSupportTicketDetailsEvent {
  const ClearDetailsFeedbackEvent();
}

/// Refresh expired evidence links without uploading or attaching again.
class RefreshSupportEvidenceUrlsEvent extends DriverSupportTicketDetailsEvent {
  const RefreshSupportEvidenceUrlsEvent();
}
