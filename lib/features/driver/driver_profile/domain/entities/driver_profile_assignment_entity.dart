class DriverProfileAssignmentEntity {
  const DriverProfileAssignmentEntity({
    this.restaurantId,
    this.restaurantName,
    this.branchId,
    this.branchName,
    this.assignedAtUtc,
  });

  final String? restaurantId;
  final String? restaurantName;
  final String? branchId;
  final String? branchName;
  final DateTime? assignedAtUtc;

  DriverProfileAssignmentEntity copyWith({
    String? restaurantId,
    String? restaurantName,
    String? branchId,
    String? branchName,
    DateTime? assignedAtUtc,
  }) {
    return DriverProfileAssignmentEntity(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      assignedAtUtc: assignedAtUtc ?? this.assignedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileAssignmentEntity &&
          runtimeType == other.runtimeType &&
          restaurantId == other.restaurantId &&
          restaurantName == other.restaurantName &&
          branchId == other.branchId &&
          branchName == other.branchName &&
          assignedAtUtc == other.assignedAtUtc;

  @override
  int get hashCode => Object.hash(
        restaurantId,
        restaurantName,
        branchId,
        branchName,
        assignedAtUtc,
      );
}
