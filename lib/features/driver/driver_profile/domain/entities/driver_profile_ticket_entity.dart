class DriverProfileTicketEntity {
  const DriverProfileTicketEntity({
    required this.ticketId,
    required this.ticketNumber,
    required this.subject,
    required this.body,
    required this.status,
    required this.statusText,
    this.priority,
    this.priorityText,
    this.createdAtUtc,
  });

  final String ticketId;
  final String ticketNumber;
  final String subject;
  final String body;
  final String status;
  final String statusText;
  final String? priority;
  final String? priorityText;
  final DateTime? createdAtUtc;

  DriverProfileTicketEntity copyWith({
    String? ticketId,
    String? ticketNumber,
    String? subject,
    String? body,
    String? status,
    String? statusText,
    String? priority,
    String? priorityText,
    DateTime? createdAtUtc,
  }) {
    return DriverProfileTicketEntity(
      ticketId: ticketId ?? this.ticketId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      priority: priority ?? this.priority,
      priorityText: priorityText ?? this.priorityText,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileTicketEntity &&
          runtimeType == other.runtimeType &&
          ticketId == other.ticketId &&
          ticketNumber == other.ticketNumber &&
          subject == other.subject &&
          body == other.body &&
          status == other.status &&
          statusText == other.statusText &&
          priority == other.priority &&
          priorityText == other.priorityText &&
          createdAtUtc == other.createdAtUtc;

  @override
  int get hashCode => Object.hash(
        ticketId,
        ticketNumber,
        subject,
        body,
        status,
        statusText,
        priority,
        priorityText,
        createdAtUtc,
      );
}
