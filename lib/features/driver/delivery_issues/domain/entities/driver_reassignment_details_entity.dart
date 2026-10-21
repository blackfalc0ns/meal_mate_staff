class DriverReassignmentDetailsEntity {
  const DriverReassignmentDetailsEntity({
    required this.requestId,
    this.boxId,
    this.boxCode,
    required this.status,
    this.reason,
    this.notes,
    this.requestedAtUtc,
    this.decision,
    this.decisionNotes,
    this.decidedByUserId,
    this.decidedAtUtc,
    this.handoverId,
    this.handoverStatus,
    this.replacementDriverId,
    this.replacementTripId,
    this.latitude,
    this.longitude,
    this.message,
  });

  final String requestId;
  final String? boxId;
  final String? boxCode;
  final String status;
  final String? reason;
  final String? notes;
  final DateTime? requestedAtUtc;
  final String? decision;
  final String? decisionNotes;
  final String? decidedByUserId;
  final DateTime? decidedAtUtc;
  final String? handoverId;
  final String? handoverStatus;
  final String? replacementDriverId;
  final String? replacementTripId;
  final double? latitude;
  final double? longitude;
  final String? message;

  bool get isRequested => status == 'ReassignmentRequested';
  bool get isAccepted => status == 'Accepted' || decision == 'Accepted';
  bool get isRejected => status == 'Rejected' || decision == 'Rejected';
  bool get isClosed => status == 'Closed';
  bool get hasHandover => handoverId != null && handoverId!.isNotEmpty;
  bool get isHandoverActive =>
      hasHandover &&
      handoverStatus != 'Completed' &&
      handoverStatus != 'Cancelled';

  DriverReassignmentDetailsEntity copyWith({
    String? requestId,
    String? boxId,
    String? boxCode,
    String? status,
    String? reason,
    String? notes,
    DateTime? requestedAtUtc,
    String? decision,
    String? decisionNotes,
    String? decidedByUserId,
    DateTime? decidedAtUtc,
    String? handoverId,
    String? handoverStatus,
    String? replacementDriverId,
    String? replacementTripId,
    double? latitude,
    double? longitude,
    String? message,
  }) {
    return DriverReassignmentDetailsEntity(
      requestId: requestId ?? this.requestId,
      boxId: boxId ?? this.boxId,
      boxCode: boxCode ?? this.boxCode,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      requestedAtUtc: requestedAtUtc ?? this.requestedAtUtc,
      decision: decision ?? this.decision,
      decisionNotes: decisionNotes ?? this.decisionNotes,
      decidedByUserId: decidedByUserId ?? this.decidedByUserId,
      decidedAtUtc: decidedAtUtc ?? this.decidedAtUtc,
      handoverId: handoverId ?? this.handoverId,
      handoverStatus: handoverStatus ?? this.handoverStatus,
      replacementDriverId: replacementDriverId ?? this.replacementDriverId,
      replacementTripId: replacementTripId ?? this.replacementTripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      message: message ?? this.message,
    );
  }
}
