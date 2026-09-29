enum DriverTicketStepState {
  completed,
  inProgress,
  pending,
}

class DriverSupportTicketTimelineStep {
  const DriverSupportTicketTimelineStep({
    required this.title,
    this.description,
    this.timestamp,
    required this.state,
    this.isHighlighted = false,
  });

  final String title;
  final String? description;
  final String? timestamp;
  final DriverTicketStepState state;
  final bool isHighlighted;
}
