import 'reassignment_reason.dart';

class ReassignmentRequestEntity {
  const ReassignmentRequestEntity({
    required this.reason,
    this.notes = '',
    this.latitude,
    this.longitude,
  });

  final ReassignmentReason reason;
  final String notes;
  final double? latitude;
  final double? longitude;

  ReassignmentRequestEntity copyWith({
    ReassignmentReason? reason,
    String? notes,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) {
    return ReassignmentRequestEntity(
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
    );
  }
}
