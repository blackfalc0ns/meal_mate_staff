import '../../domain/entities/driver_call_proxy_entity.dart';
import '../../domain/entities/driver_delivery_manifest_entity.dart';
import '../../domain/entities/driver_delivery_status.dart';
import '../../domain/entities/driver_delivery_stop_entity.dart';
import '../models/response/driver_call_proxy_response_dto.dart';
import '../models/response/driver_delivery_manifest_response_dto.dart';

extension DriverDeliveryManifestMapper on DriverDeliveryManifestResponseDto {
  DriverDeliveryManifestEntity toEntity() {
    DateTime? parsedServerTime;
    if (serverTimeUtc != null) {
      parsedServerTime = DateTime.tryParse(serverTimeUtc!)?.toUtc();
    }

    final mappedStops = (stops ?? [])
        .map((s) => s.toEntity())
        .toList();

    mappedStops.sort((a, b) {
      final cmp = a.sequenceNumber.compareTo(b.sequenceNumber);
      if (cmp != 0) return cmp;
      return a.boxId.compareTo(b.boxId);
    });

    final total = (counts?.total ?? 0).clamp(0, 999999);
    final inProgress = (counts?.inProgress ?? 0).clamp(0, 999999);
    final delivered = (counts?.delivered ?? 0).clamp(0, 999999);
    final failed = (counts?.failed ?? 0).clamp(0, 999999);

    return DriverDeliveryManifestEntity(
      tripId: tripId,
      tripCode: tripCode,
      tripStatus: tripStatus,
      tripStatusText: tripStatusText,
      serverTimeUtc: parsedServerTime,
      totalCount: total,
      inProgressCount: inProgress,
      deliveredCount: delivered,
      failedCount: failed,
      stops: mappedStops,
    );
  }
}

extension DriverDeliveryStopMapper on DriverDeliveryStopResponseDto {
  DriverDeliveryStopEntity toEntity() {
    DateTime? parsedDeliveredAt;
    if (deliveredAtUtc != null) {
      parsedDeliveredAt = DateTime.tryParse(deliveredAtUtc!)?.toUtc();
    }

    return DriverDeliveryStopEntity(
      tripStopId: tripStopId ?? '',
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      sequenceNumber: sequenceNumber ?? 0,
      customerName: customerName?.trim() ?? '',
      deliveryZone: deliveryZone?.trim() ?? '',
      formattedAddress: formattedAddress?.trim() ?? '',
      latitude: latitude?.toDouble(),
      longitude: longitude?.toDouble(),
      mealsCount: (mealsCount ?? 0).clamp(0, 999),
      mealsSummary: mealsSummary?.trim() ?? '',
      deliveryTimeSlot: deliveryTimeSlot?.trim() ?? '',
      status: DriverDeliveryStatusX.fromWire(status),
      statusText: statusText?.trim() ?? '',
      deliveredAtUtc: parsedDeliveredAt,
      failureReasonCategory: failureReasonCategory,
      failureReasonText: failureReasonText,
      isCurrentStop: isCurrentStop ?? false,
      canCompleteDelivery: canCompleteDelivery ?? false,
      canNavigate: canNavigate ?? false,
      canCallCustomer: canCallCustomer ?? false,
      maskedPhoneNumber: (maskedPhoneNumber != null &&
              maskedPhoneNumber!.trim().isNotEmpty)
          ? maskedPhoneNumber!.trim()
          : null,
    );
  }
}

extension DriverCallProxyMapper on DriverCallProxyResponseDto {
  DriverCallProxyEntity toEntity() {
    DateTime? parsedExpiresAt;
    if (expiresAtUtc != null) {
      parsedExpiresAt = DateTime.tryParse(expiresAtUtc!)?.toUtc();
    }

    return DriverCallProxyEntity(
      boxId: boxId ?? '',
      callableUri: callableUri?.trim() ?? '',
      phoneNumber: (phoneNumber != null && phoneNumber!.trim().isNotEmpty)
          ? phoneNumber!.trim()
          : null,
      expiresAtUtc: parsedExpiresAt,
    );
  }
}
