class DispatcherDriverLocationEntity {
  const DispatcherDriverLocationEntity({
    this.areaName = '',
    this.updatedMinutesAgo = 0,
    this.mapPreviewAsset = '',
    this.latitude,
    this.longitude,
    this.updatedAtUtc,
  });

  final String areaName;
  final int updatedMinutesAgo;
  final String mapPreviewAsset;
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAtUtc;

  bool get hasCoordinates => latitude != null && longitude != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverLocationEntity &&
          runtimeType == other.runtimeType &&
          areaName == other.areaName &&
          updatedMinutesAgo == other.updatedMinutesAgo &&
          mapPreviewAsset == other.mapPreviewAsset &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          updatedAtUtc == other.updatedAtUtc;

  @override
  int get hashCode => Object.hash(
    areaName,
    updatedMinutesAgo,
    mapPreviewAsset,
    latitude,
    longitude,
    updatedAtUtc,
  );
}
