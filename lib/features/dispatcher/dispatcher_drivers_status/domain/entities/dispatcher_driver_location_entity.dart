class DispatcherDriverLocationEntity {
  const DispatcherDriverLocationEntity({
    required this.areaName,
    required this.updatedMinutesAgo,
    required this.mapPreviewAsset,
    required this.latitude,
    required this.longitude,
  });

  final String areaName;
  final int updatedMinutesAgo;
  final String mapPreviewAsset;
  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverLocationEntity &&
          runtimeType == other.runtimeType &&
          areaName == other.areaName &&
          updatedMinutesAgo == other.updatedMinutesAgo &&
          mapPreviewAsset == other.mapPreviewAsset &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(
    areaName,
    updatedMinutesAgo,
    mapPreviewAsset,
    latitude,
    longitude,
  );
}
