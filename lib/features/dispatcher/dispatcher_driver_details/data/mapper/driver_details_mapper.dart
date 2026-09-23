import '../../domain/entities/driver_active_box_entity.dart';
import '../../domain/entities/driver_current_location_entity.dart';
import '../../domain/entities/driver_daily_summary_entity.dart';
import '../../domain/entities/driver_details_entity.dart';
import '../../domain/entities/driver_details_status.dart';
import '../../domain/entities/driver_kpis_entity.dart';
import '../../domain/entities/driver_location_point_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../models/response/driver_active_boxes_response_dto.dart';
import '../models/response/driver_current_location_response_dto.dart';
import '../models/response/driver_details_response_dto.dart';

List<DriverLocationPointEntity> parseRoutePolyline(String? polyline) {
  if (polyline == null || polyline.trim().isEmpty) {
    return const [];
  }
  final points = <DriverLocationPointEntity>[];
  final pairs = polyline.split(';');
  for (final pair in pairs) {
    final trimmedPair = pair.trim();
    if (trimmedPair.isEmpty) continue;
    final coords = trimmedPair.split(',');
    if (coords.length != 2) continue;
    final lat = double.tryParse(coords[0].trim());
    final lng = double.tryParse(coords[1].trim());
    if (lat == null || lng == null) continue;
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) continue;
    points.add(DriverLocationPointEntity(latitude: lat, longitude: lng));
  }
  if (points.length < 2) {
    return const [];
  }
  return List.unmodifiable(points);
}

extension DriverDetailsResponseDtoMapper on DriverDetailsResponseDto {
  DriverDetailsEntity toEntity() {
    final p = driver;
    final k = kpis;
    final s = dailySummary;

    return DriverDetailsEntity(
      driver: DriverProfileEntity(
        driverId: p?.driverId ?? '',
        driverCode: p?.driverCode ?? '',
        fullName: p?.fullName ?? '',
        phoneNumber: p?.phoneNumber,
        avatarUrl: p?.avatarUrl,
        status: DriverDetailsStatusX.fromApi(p?.status),
        statusText: p?.statusText ?? '',
        statusDotColor: p?.statusDotColor,
        lastUpdatedText: p?.lastUpdatedText ?? '',
      ),
      kpis: DriverKpisEntity(
        performanceRating: (k?.performanceRating?.toDouble()) ?? 0.0,
        avgDelayMinutes: (k?.avgDelayMinutes?.toInt()) ?? 0,
        deliveredTodayCount: (k?.deliveredTodayCount?.toInt()) ?? 0,
        activeBoxesCount: (k?.activeBoxesCount?.toInt()) ?? 0,
      ),
      dailySummary: DriverDailySummaryEntity(
        approxKm: (s?.approxKm?.toInt()) ?? 0,
        avgDelayMinutes: (s?.avgDelayMinutes?.toInt()) ?? 0,
        failedDeliveryCount: (s?.failedDeliveryCount?.toInt()) ?? 0,
        deliveredCount: (s?.deliveredCount?.toInt()) ?? 0,
      ),
    );
  }
}

extension DriverActiveBoxesResponseDtoMapper on DriverActiveBoxesResponseDto {
  List<DriverActiveBoxEntity> toEntityList() {
    if (boxes == null) return const [];
    final list = <DriverActiveBoxEntity>[];
    for (final b in boxes!) {
      if (b == null) continue;
      list.add(
        DriverActiveBoxEntity(
          boxId: b.boxId ?? '',
          boxCode: b.boxCode ?? '',
          customerName: b.customerName ?? '',
          deliveryAddress: b.deliveryAddress ?? '',
          status: b.status ?? '',
          statusText: b.statusText ?? '',
          statusColor: b.statusColor,
          scheduledTimeText: b.scheduledTimeText ?? '',
          isDelivering: b.isDelivering ?? false,
        ),
      );
    }
    return List.unmodifiable(list);
  }
}

extension DriverCurrentLocationResponseDtoMapper
    on DriverCurrentLocationResponseDto {
  DriverCurrentLocationEntity toEntity() {
    return DriverCurrentLocationEntity(
      latitude: latitude?.toDouble(),
      longitude: longitude?.toDouble(),
      heading: heading?.toDouble(),
      speed: speed?.toDouble(),
      destinationLatitude: destinationLatitude?.toDouble(),
      destinationLongitude: destinationLongitude?.toDouble(),
      statusBadgeText: statusBadgeText ?? '',
      timeAgoText: timeAgoText ?? '',
      streetName: streetName ?? '',
      areaName: areaName ?? '',
      routePoints: parseRoutePolyline(routePolyline),
      recordedAt: recordedAt,
    );
  }
}
