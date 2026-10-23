import '../../domain/entities/driver_support_ticket_status.dart';

sealed class DriverSupportTicketsEvent {
  const DriverSupportTicketsEvent();
}

class LoadDriverSupportTicketsEvent extends DriverSupportTicketsEvent {
  const LoadDriverSupportTicketsEvent();
}

class ChangeDriverSupportTicketFilterEvent extends DriverSupportTicketsEvent {
  const ChangeDriverSupportTicketFilterEvent(this.filter);
  final DriverSupportTicketFilter filter;
}

class SearchDriverSupportTicketsEvent extends DriverSupportTicketsEvent {
  const SearchDriverSupportTicketsEvent(this.query);
  final String query;
}

class LoadMoreDriverSupportTicketsEvent extends DriverSupportTicketsEvent {
  const LoadMoreDriverSupportTicketsEvent();
}

class RefreshDriverSupportTicketsEvent extends DriverSupportTicketsEvent {
  const RefreshDriverSupportTicketsEvent({this.onCompleted});
  final void Function()? onCompleted;
}

class RetryDriverSupportTicketsEvent extends DriverSupportTicketsEvent {
  const RetryDriverSupportTicketsEvent();
}

class OnRealtimeTicketUpdatedEvent extends DriverSupportTicketsEvent {
  const OnRealtimeTicketUpdatedEvent({this.issueId});
  final String? issueId;
}

class OnRealtimeReconnectedEvent extends DriverSupportTicketsEvent {
  const OnRealtimeReconnectedEvent();
}

class ClearTicketsFeedbackEvent extends DriverSupportTicketsEvent {
  const ClearTicketsFeedbackEvent();
}
