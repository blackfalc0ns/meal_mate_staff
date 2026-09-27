import 'package:flutter/foundation.dart';

import 'driver_delivery_stop_entity.dart';

class DriverDeliveryManifestEntity {
  DriverDeliveryManifestEntity({
    this.tripId,
    this.tripCode,
    this.tripStatus,
    this.tripStatusText,
    this.serverTimeUtc,
    required this.totalCount,
    required this.inProgressCount,
    required this.deliveredCount,
    required this.failedCount,
    required List<DriverDeliveryStopEntity> stops,
  }) : stops = List.unmodifiable(stops);

  const DriverDeliveryManifestEntity.empty()
    : tripId = null,
      tripCode = null,
      tripStatus = null,
      tripStatusText = null,
      serverTimeUtc = null,
      totalCount = 0,
      inProgressCount = 0,
      deliveredCount = 0,
      failedCount = 0,
      stops = const [];

  final String? tripId;
  final String? tripCode;
  final String? tripStatus;
  final String? tripStatusText;
  final DateTime? serverTimeUtc;
  final int totalCount;
  final int inProgressCount;
  final int deliveredCount;
  final int failedCount;
  final List<DriverDeliveryStopEntity> stops;

  bool get hasActiveTrip => tripId != null && tripId!.isNotEmpty;
  bool get isEmpty => stops.isEmpty;

  DriverDeliveryManifestEntity copyWith({
    String? tripId,
    String? tripCode,
    String? tripStatus,
    String? tripStatusText,
    DateTime? serverTimeUtc,
    int? totalCount,
    int? inProgressCount,
    int? deliveredCount,
    int? failedCount,
    List<DriverDeliveryStopEntity>? stops,
  }) {
    return DriverDeliveryManifestEntity(
      tripId: tripId ?? this.tripId,
      tripCode: tripCode ?? this.tripCode,
      tripStatus: tripStatus ?? this.tripStatus,
      tripStatusText: tripStatusText ?? this.tripStatusText,
      serverTimeUtc: serverTimeUtc ?? this.serverTimeUtc,
      totalCount: totalCount ?? this.totalCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      failedCount: failedCount ?? this.failedCount,
      stops: stops ?? this.stops,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverDeliveryManifestEntity &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId &&
          tripCode == other.tripCode &&
          tripStatus == other.tripStatus &&
          tripStatusText == other.tripStatusText &&
          serverTimeUtc == other.serverTimeUtc &&
          totalCount == other.totalCount &&
          inProgressCount == other.inProgressCount &&
          deliveredCount == other.deliveredCount &&
          failedCount == other.failedCount &&
          listEquals(stops, other.stops);

  @override
  int get hashCode => Object.hash(
    tripId,
    tripCode,
    tripStatus,
    tripStatusText,
    serverTimeUtc,
    totalCount,
    inProgressCount,
    deliveredCount,
    failedCount,
    Object.hashAll(stops),
  );
}
