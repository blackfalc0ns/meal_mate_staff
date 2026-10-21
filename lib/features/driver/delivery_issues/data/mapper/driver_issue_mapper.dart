import '../../domain/entities/delivery_issue_reason.dart';
import '../models/request/driver_report_delay_request_dto.dart';
import '../models/request/driver_report_issue_request_dto.dart';

class DriverIssueReasonMapper {
  const DriverIssueReasonMapper._();

  static DeliveryIssueReason fromWire(String wire) {
    return switch (wire) {
      'AddressIssue' => DeliveryIssueReason.addressIssue,
      'SevereDelay' => DeliveryIssueReason.severeDelay,
      'RoadIssue' => DeliveryIssueReason.roadIssue,
      'VehicleBreakdown' => DeliveryIssueReason.vehicleBreakdown,
      'TrafficAccident' => DeliveryIssueReason.trafficAccident,
      'SevereWeather' => DeliveryIssueReason.severeWeather,
      'CustomerUnavailable' => DeliveryIssueReason.customerUnavailable,
      'CustomerRefusal' => DeliveryIssueReason.customerRefusal,
      'DamagedBox' => DeliveryIssueReason.damagedBox,
      'Other' => DeliveryIssueReason.other,
      _ => DeliveryIssueReason.other,
    };
  }
}

class DriverIssueMapper {
  const DriverIssueMapper._();

  static DriverReportIssueRequestDto toReportDto({
    required DeliveryIssueReason reason,
    String? description,
    String? severity,
    List<String>? photoStorageKeys = const [],
  }) {
    final trimmedDesc = description?.trim();
    final normalizedDesc = (trimmedDesc == null || trimmedDesc.isEmpty)
        ? null
        : (trimmedDesc.length > 250
            ? trimmedDesc.substring(0, 250)
            : trimmedDesc);

    final normalizedSeverity = (severity == null || severity.trim().isEmpty)
        ? 'Medium'
        : severity.trim();

    final uniqueKeys = (photoStorageKeys ?? const [])
        .map((k) => k.trim())
        .where((k) {
          if (k.isEmpty) return false;
          final lower = k.toLowerCase();
          if (lower.startsWith('assets/')) return false;
          if (lower.startsWith('http://') || lower.startsWith('https://')) return false;
          if (lower.startsWith('/') || lower.startsWith('\\')) return false;
          if (RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(k)) return false;
          return true;
        })
        .toSet()
        .take(3)
        .toList();

    return DriverReportIssueRequestDto(
      issueType: reason.wireValue,
      description: normalizedDesc,
      severity: normalizedSeverity,
      evidencePhotoStorageKey: uniqueKeys.isEmpty ? null : uniqueKeys.first,
      evidencePhotoStorageKeys: uniqueKeys.isEmpty ? null : uniqueKeys,
    );
  }

  static DriverReportDelayRequestDto toDelayDto({
    required int delayMinutes,
    String? reason,
  }) {
    if (delayMinutes < 1 || delayMinutes > 1440) {
      throw ArgumentError.value(
        delayMinutes,
        'delayMinutes',
        'Delay minutes must be between 1 and 1440',
      );
    }

    final trimmedReason = reason?.trim();
    final normalizedReason = (trimmedReason == null || trimmedReason.isEmpty)
        ? null
        : trimmedReason;

    return DriverReportDelayRequestDto(
      delayMinutes: delayMinutes,
      reason: normalizedReason,
    );
  }
}
