import 'package:meal_mate_delivery/core/constants/assets.dart';
import '../../../orders/domain/entities/driver_delivery_status.dart';
import '../../domain/entities/driver_map_location_entity.dart';
import '../../domain/entities/driver_map_navigation_entity.dart';
import '../../domain/entities/driver_map_route_entity.dart';
import '../../domain/entities/driver_map_route_status.dart';
import '../../domain/entities/driver_map_stop_entity.dart';
import '../../domain/entities/driver_map_unavailable_reason.dart';
import '../models/response/driver_map_location_response_dto.dart';
import '../models/response/driver_map_navigation_response_dto.dart';
import '../models/response/driver_map_route_response_dto.dart';
import '../models/response/driver_map_stop_response_dto.dart';

extension DriverMapRouteResponseDtoMapper on DriverMapRouteResponseDto {
  DriverMapRouteEntity toEntity() {
    final mappedStops = stops
            ?.where((s) => s.stopId != null && s.stopId!.trim().isNotEmpty)
            .map((s) => s.toEntity(totalStopsCount: totalStopsCount ?? stops?.length ?? 1))
            .toList() ??
        const [];

    DriverMapStopEntity resolvedFocusedStop;
    if (focusedStop != null && focusedStop!.stopId != null && focusedStop!.stopId!.isNotEmpty) {
      resolvedFocusedStop = focusedStop!.toEntity(
        totalStopsCount: totalStopsCount ?? mappedStops.length,
      );
    } else if (mappedStops.isNotEmpty) {
      resolvedFocusedStop = mappedStops.firstWhere(
        (s) => s.isCurrent,
        orElse: () => mappedStops.first,
      );
    } else {
      resolvedFocusedStop = const DriverMapStopEntity(
        id: '',
        boxCode: '',
        customerName: '',
        area: '',
        formattedAddress: '',
        mealsCount: 0,
        deliveryTimeSlot: '',
        status: DriverDeliveryStatus.unknown,
      );
    }

    return DriverMapRouteEntity(
      tripId: tripId ?? '',
      tripCode: tripCode ?? '',
      totalStopsCount: totalStopsCount ?? mappedStops.length,
      completedStopsCount: completedStopsCount ?? 0,
      focusedStop: resolvedFocusedStop,
      stops: mappedStops,
      navigation: navigation?.toEntity(),
    );
  }
}

extension DriverMapStopResponseDtoMapper on DriverMapStopResponseDto {
  DriverMapStopEntity toEntity({int totalStopsCount = 1}) {
    final cleanShortAddress = addressShort?.trim() ?? '';
    final cleanFullAddress = fullAddress?.trim() ?? '';
    final address = cleanFullAddress.isNotEmpty ? cleanFullAddress : cleanShortAddress;

    final resolvedArea = cleanShortAddress.isNotEmpty
        ? cleanShortAddress
        : (cleanFullAddress.isNotEmpty ? cleanFullAddress.split(',').first.trim() : '');

    return DriverMapStopEntity(
      id: stopId?.trim() ?? '',
      boxCode: boxCode ?? '',
      sequenceNumber: sequenceNumber ?? 1,
      totalStops: totalStopsCount > 0 ? totalStopsCount : 1,
      sequenceBadge: sequenceBadge,
      customerName: customerName ?? '',
      customerPhone: '', // Rule: customerPhone is strictly empty in the driver map
      area: resolvedArea,
      formattedAddress: address,
      mealsCount: mealsCount ?? 0,
      mealsSummary: mealsSummary,
      deliveryTimeSlot: deliveryTimeSlot ?? '',
      status: mapDriverMapStopStatus(status),
      statusText: statusText,
      statusColor: _normalizeStatusColor(statusColor),
      isCurrent: isCurrent ?? false,
      latitude: latitude,
      longitude: longitude,
      imageAsset: AppAssets.driverKpiBox,
    );
  }

  static DriverDeliveryStatus mapDriverMapStopStatus(String? value) =>
      switch (value) {
        'InTransit' => DriverDeliveryStatus.inProgress,
        'Pending' => DriverDeliveryStatus.pending,
        'Delivered' => DriverDeliveryStatus.delivered,
        _ => DriverDeliveryStatus.unknown,
      };

  static String? _normalizeStatusColor(String? color) {
    if (color == null) return null;
    final normalized = color.trim().toLowerCase();
    if (normalized == 'gray' || normalized == 'green' || normalized == 'orange') {
      return normalized;
    }
    return null;
  }
}

extension DriverMapLocationResponseDtoMapper on DriverMapLocationResponseDto {
  DriverMapLocationEntity toEntity() {
    DateTime? parsedDate;
    if (recordedAtUtc != null && recordedAtUtc!.trim().isNotEmpty) {
      parsedDate = DateTime.tryParse(recordedAtUtc!.trim())?.toUtc();
    }

    return DriverMapLocationEntity(
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      label: label ?? '',
      source: source ?? '',
      recordedAtUtc: parsedDate,
      isStale: isStale ?? false,
      heading: heading,
    );
  }
}

extension DriverMapNavigationResponseDtoMapper on DriverMapNavigationResponseDto {
  DriverMapNavigationEntity toEntity() {
    DateTime? parsedArrival;
    if (estimatedArrivalAtUtc != null && estimatedArrivalAtUtc!.trim().isNotEmpty) {
      parsedArrival = DateTime.tryParse(estimatedArrivalAtUtc!.trim())?.toUtc();
    }

    DateTime? parsedCalculated;
    if (calculatedAtUtc != null && calculatedAtUtc!.trim().isNotEmpty) {
      parsedCalculated = DateTime.tryParse(calculatedAtUtc!.trim())?.toUtc();
    }

    return DriverMapNavigationEntity(
      destinationStopId: destinationStopId,
      origin: origin != null && origin!.latitude != null && origin!.longitude != null
          ? origin!.toEntity()
          : null,
      destination: destination != null &&
              destination!.latitude != null &&
              destination!.longitude != null
          ? destination!.toEntity()
          : null,
      routeStatus: _parseRouteStatus(routeStatus),
      unavailableReason: _parseUnavailableReason(unavailableReason),
      encodedPolyline: encodedPolyline,
      polylineEncoding: polylineEncoding ?? 'google_polyline5',
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      estimatedArrivalAtUtc: parsedArrival,
      calculatedAtUtc: parsedCalculated,
      googleMapsUrl: googleMapsUrl,
      canNavigate: canNavigate ?? false,
    );
  }

  static DriverMapRouteStatus _parseRouteStatus(String? value) => switch (value) {
        'Ready' => DriverMapRouteStatus.ready,
        'Unavailable' => DriverMapRouteStatus.unavailable,
        'Completed' => DriverMapRouteStatus.completed,
        _ => DriverMapRouteStatus.unknown,
      };

  static DriverMapUnavailableReason? _parseUnavailableReason(String? value) =>
      switch (value) {
        'driver_location_missing' =>
          DriverMapUnavailableReason.driverLocationMissing,
        'driver_location_stale' =>
          DriverMapUnavailableReason.driverLocationStale,
        'driver_location_invalid' =>
          DriverMapUnavailableReason.driverLocationInvalid,
        'destination_location_missing' =>
          DriverMapUnavailableReason.destinationLocationMissing,
        'directions_unavailable' =>
          DriverMapUnavailableReason.directionsUnavailable,
        _ when value != null && value.trim().isNotEmpty =>
          DriverMapUnavailableReason.unknown,
        _ => null,
      };
}
