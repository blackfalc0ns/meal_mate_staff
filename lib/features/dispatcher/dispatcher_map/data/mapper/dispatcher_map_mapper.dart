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

(double, double)? resolveZoneCoordinates(
  String? zone, {
  String driverId = '',
}) {
  if (zone == null || zone.trim().isEmpty) return null;
  final normalized = zone.trim().toLowerCase();

  (double, double)? base;
  if (normalized.contains('yarmouk') || normalized.contains('يرموك')) {
    base = const (29.3080, 47.9620);
  } else if (normalized.contains('capital') ||
      normalized.contains('عاصمة') ||
      normalized.contains('مدينة الكويت') ||
      normalized.contains('kuwait city') ||
      normalized.contains('downtown')) {
    base = const (29.3759, 47.9774);
  } else if (normalized.contains('salmiya') || normalized.contains('سالمية')) {
    base = const (29.3333, 48.0833);
  } else if (normalized.contains('hawall') || normalized.contains('حولي')) {
    base = const (29.3328, 48.0282);
  } else if (normalized.contains('farwaniya') ||
      normalized.contains('فروانية')) {
    base = const (29.2784, 47.9585);
  } else if (normalized.contains('ahmadi') ||
      normalized.contains('أحمدي') ||
      normalized.contains('احمدي')) {
    base = const (29.0769, 48.0839);
  } else if (normalized.contains('jahra') || normalized.contains('جهراء')) {
    base = const (29.3375, 47.6581);
  } else if (normalized.contains('mubarak') || normalized.contains('مبارك')) {
    base = const (29.2081, 48.0772);
  } else if (normalized.contains('shaab') || normalized.contains('شعب')) {
    base = const (29.3550, 48.0200);
  } else if (normalized.contains('dasman') || normalized.contains('دسمان')) {
    base = const (29.3880, 48.0010);
  } else if (normalized.contains('sharq') || normalized.contains('شرق')) {
    base = const (29.3850, 47.9890);
  } else if (normalized.contains('khaitan') || normalized.contains('خيطان')) {
    base = const (29.2941, 47.9742);
  } else if (normalized.contains('fahaheel') || normalized.contains('فحيحيل')) {
    base = const (29.0831, 48.1322);
  } else if (normalized.contains('shuwaikh') || normalized.contains('شويخ')) {
    base = const (29.3500, 47.9300);
  } else if (normalized.contains('sabah al salem') ||
      normalized.contains('صباح السالم')) {
    base = const (29.2550, 48.0750);
  } else if (normalized.contains('mangaf') ||
      normalized.contains('منقف') ||
      normalized.contains('المنقف')) {
    base = const (29.0967, 48.1306);
  } else if (normalized.contains('mahboula') ||
      normalized.contains('مهبولة') ||
      normalized.contains('المهبولة')) {
    base = const (29.1417, 48.1250);
  }

  if (base == null) return null;
  if (driverId.isEmpty) return base;

  final hash = driverId.hashCode.abs();
  final offsetLat = ((hash % 9) - 4) * 0.0035;
  final offsetLng = (((hash ~/ 9) % 9) - 4) * 0.0035;
  return (base.$1 + offsetLat, base.$2 + offsetLng);
}

extension DispatcherMapDriverResponseDtoMapper
    on DispatcherMapDriverResponseDto {
  DispatcherMapDriverEntity toEntity() {
    final effectiveDriverId = driverId ?? id ?? '';
    final hasDirectCoords = latitude != null &&
        longitude != null &&
        latitude!.isFinite &&
        longitude!.isFinite &&
        latitude! >= -90 &&
        latitude! <= 90 &&
        longitude! >= -180 &&
        longitude! <= 180 &&
        !(latitude == 0 && longitude == 0);

    final resolvedCoords = hasDirectCoords
        ? (latitude!, longitude!)
        : resolveZoneCoordinates(locationZone, driverId: effectiveDriverId);

    return DispatcherMapDriverEntity(
      id: effectiveDriverId,
      driverCode: driverCode,
      name: driverName ?? name ?? '',
      phoneNumber: phone ?? phoneNumber,
      plateNumber: plateNumber,
      avatarUrl: avatarUrl,
      boxId: boxCode ?? boxId ?? '',
      tripId: tripId,
      latitude: resolvedCoords?.$1,
      longitude: resolvedCoords?.$2,
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
