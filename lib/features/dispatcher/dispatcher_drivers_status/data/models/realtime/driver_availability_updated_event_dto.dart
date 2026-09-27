class DriverAvailabilityUpdatedEventDto {
  const DriverAvailabilityUpdatedEventDto({
    required this.driverId,
    required this.isAvailable,
    this.operationalStatus,
    this.hasActiveAssignments,
    this.updatedAtUtc,
  });

  factory DriverAvailabilityUpdatedEventDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final driverId =
        json['driverId'] as String? ??
        json['DriverId'] as String? ??
        json['id'] as String? ??
        '';
    final isAvailable =
        json['isAvailable'] as bool? ?? json['IsAvailable'] as bool? ?? false;
    final operationalStatus =
        json['operationalStatus'] as String? ??
        json['OperationalStatus'] as String?;
    final hasActiveAssignments =
        json['hasActiveAssignments'] as bool? ??
        json['HasActiveAssignments'] as bool?;
    final updatedAtUtc =
        json['updatedAtUtc'] as String? ?? json['UpdatedAtUtc'] as String?;

    return DriverAvailabilityUpdatedEventDto(
      driverId: driverId,
      isAvailable: isAvailable,
      operationalStatus: operationalStatus,
      hasActiveAssignments: hasActiveAssignments,
      updatedAtUtc: updatedAtUtc,
    );
  }

  final String driverId;
  final bool isAvailable;
  final String? operationalStatus;
  final bool? hasActiveAssignments;
  final String? updatedAtUtc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverAvailabilityUpdatedEventDto &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          isAvailable == other.isAvailable &&
          operationalStatus == other.operationalStatus &&
          hasActiveAssignments == other.hasActiveAssignments &&
          updatedAtUtc == other.updatedAtUtc;

  @override
  int get hashCode => Object.hash(
    driverId,
    isAvailable,
    operationalStatus,
    hasActiveAssignments,
    updatedAtUtc,
  );
}
