class AssignDriverRequestEntity {
  const AssignDriverRequestEntity({
    required this.boxId,
    required this.driverId,
    required this.notes,
  });

  final String boxId;
  final String driverId;
  final String notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignDriverRequestEntity &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          driverId == other.driverId &&
          notes == other.notes;

  @override
  int get hashCode => boxId.hashCode ^ driverId.hashCode ^ notes.hashCode;
}
