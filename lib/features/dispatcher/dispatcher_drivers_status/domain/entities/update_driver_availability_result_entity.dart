import 'dispatcher_driver_status_type.dart';

class UpdateDriverAvailabilityResultEntity {
  const UpdateDriverAvailabilityResultEntity({
    required this.driverId,
    required this.isAvailable,
    required this.operationalStatus,
    this.updatedAtUtc,
  });

  final String driverId;
  final bool isAvailable;
  final DispatcherDriverStatusType operationalStatus;
  final DateTime? updatedAtUtc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDriverAvailabilityResultEntity &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          isAvailable == other.isAvailable &&
          operationalStatus == other.operationalStatus &&
          updatedAtUtc == other.updatedAtUtc;

  @override
  int get hashCode =>
      Object.hash(driverId, isAvailable, operationalStatus, updatedAtUtc);
}
