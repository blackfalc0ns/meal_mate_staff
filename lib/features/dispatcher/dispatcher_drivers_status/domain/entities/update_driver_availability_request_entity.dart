import '../../data/models/request/update_driver_availability_request_dto.dart';

class UpdateDriverAvailabilityRequestEntity {
  const UpdateDriverAvailabilityRequestEntity({
    required this.driverId,
    required this.isAvailable,
    this.reason,
  });

  final String driverId;
  final bool isAvailable;
  final String? reason;

  UpdateDriverAvailabilityRequestDto toDto() {
    final trimmedReason = reason?.trim();
    return UpdateDriverAvailabilityRequestDto(
      isAvailable: isAvailable,
      reason: (trimmedReason != null && trimmedReason.isNotEmpty)
          ? trimmedReason
          : null,
    );
  }
}
