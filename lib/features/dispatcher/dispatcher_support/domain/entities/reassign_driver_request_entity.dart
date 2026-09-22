class ReassignDriverRequestEntity {
  const ReassignDriverRequestEntity({
    required this.replacementDriverId,
    this.notes,
  });

  final String replacementDriverId;
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReassignDriverRequestEntity &&
          runtimeType == other.runtimeType &&
          replacementDriverId == other.replacementDriverId &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(replacementDriverId, notes);
}
