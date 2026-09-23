import '../../domain/entities/dispatcher_live_monitoring_entity.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import '../../domain/entities/dispatcher_map_driver_status.dart';
import '../../domain/entities/dispatcher_map_kpi_entity.dart';
import '../models/response/dispatcher_live_monitoring_response_dto.dart';
export 'dispatcher_map_realtime_mapper.dart';

extension DispatcherMapStatusStringMapper on String? {
  DispatcherMapDriverStatus toDriverStatus() {
    final normalized = this?.trim().toLowerCase();
    return switch (normalized) {
      'indelivery' => DispatcherMapDriverStatus.inDelivery,
      'loading' => DispatcherMapDriverStatus.onTheWayToLoad,
      'paused' => DispatcherMapDriverStatus.paused,
      'attentionrequired' => DispatcherMapDriverStatus.hasIssue,
      _ => DispatcherMapDriverStatus.unknown,
    };
  }
}

DateTime? _parseNullableTimestamp(String? timestamp) {
  if (timestamp == null || timestamp.isEmpty) return null;
  return DateTime.tryParse(timestamp)?.toUtc();
}

extension DispatcherLiveMonitoringResponseDtoMapper
    on DispatcherLiveMonitoringResponseDto {
  DispatcherLiveMonitoringEntity toEntity() {
    return DispatcherLiveMonitoringEntity(
      kpi: kpis.toEntity(),
      drivers: drivers?.map((d) => d.toEntity()).toList() ?? const [],
    );
  }
}

extension DispatcherMapKpiResponseDtoMapper on DispatcherMapKpiResponseDto? {
  DispatcherMapKpiEntity toEntity() {
    return DispatcherMapKpiEntity(
      activeDriversCount: this?.activeDriversCount ?? 0,
      inDeliveryCount: this?.inDeliveryCount ?? 0,
      pausedCount: this?.pausedCount ?? 0,
      issuesCount: this?.attentionRequiredCount ?? this?.issuesCount ?? 0,
    );
  }
}

extension DispatcherMapDriverResponseDtoMapper
    on DispatcherMapDriverResponseDto {
  DispatcherMapDriverEntity toEntity() {
    return DispatcherMapDriverEntity(
      id: driverId ?? id ?? '',
      driverCode: driverCode,
      name: driverName ?? name ?? '',
      phoneNumber: phone ?? phoneNumber,
      plateNumber: plateNumber,
      avatarUrl: avatarUrl,
      boxId: boxCode ?? boxId ?? '',
      tripId: tripId,
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      speed: speedKmh ?? speed,
      lastLocationTimestamp: _parseNullableTimestamp(
        updatedAtUtc ?? lastLocationTimestamp,
      ),
      status: (statusCategory ?? status).toDriverStatus(),
      statusText: statusText,
      statusColor: topIndicatorColor ?? statusColor,
      hasIssue: hasIssue ?? false,
      issueDescription: issueDescription,
      lastStatusTimestamp: _parseNullableTimestamp(
        updatedAtUtc ?? lastStatusTimestamp,
      ),
      locationZone: locationZone,
      remainingDistanceKm: remainingDistanceKm,
      remainingDistanceText: remainingDistanceText,
      remainingDeliveryValue: remainingDeliveryValue,
    );
  }
}
