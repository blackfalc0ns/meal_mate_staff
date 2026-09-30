import 'reassignment_reason.dart';

class ReassignmentRequestEntity {
  const ReassignmentRequestEntity({
    required this.reason,
    this.notes = '',
  });

  final ReassignmentReason reason;
  final String notes;

  ReassignmentRequestEntity copyWith({
    ReassignmentReason? reason,
    String? notes,
  }) {
    return ReassignmentRequestEntity(
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
    );
  }
}
