class DriverAssignmentResultEntity {
  const DriverAssignmentResultEntity({
    required this.success,
    required this.message,
    this.assignedAt,
    this.boxId,
    this.driverId,
  });

  final bool success;
  final String message;
  final DateTime? assignedAt;
  final String? boxId;
  final String? driverId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverAssignmentResultEntity &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          message == other.message &&
          assignedAt == other.assignedAt &&
          boxId == other.boxId &&
          driverId == other.driverId;

  @override
  int get hashCode =>
      success.hashCode ^
      message.hashCode ^
      assignedAt.hashCode ^
      boxId.hashCode ^
      driverId.hashCode;
}
