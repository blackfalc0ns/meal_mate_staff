import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/widget/map_markers/app_map_marker_bitmap_factory.dart';

export 'package:meal_mate_delivery/core/widget/map_markers/app_map_marker_bitmap_factory.dart';

class DriverMapMarkerBitmapFactory {
  DriverMapMarkerBitmapFactory._();

  static const String driverCacheKey = AppMapMarkerBitmapFactory.driverCacheKey;

  static String stopCacheKey(
    String stopId,
    String boxCode, {
    required bool isSelected,
  }) {
    return AppMapMarkerBitmapFactory.stopCacheKey(
      stopId,
      boxCode,
      isSelected: isSelected,
    );
  }

  static void clearCache() {
    AppMapMarkerBitmapFactory.clearCache();
  }

  static Future<BitmapDescriptor> createDriverMarker(BuildContext context) {
    return AppMapMarkerBitmapFactory.createDriverMarker(context);
  }

  static Future<BitmapDescriptor> createStopMarker(
    BuildContext context, {
    required String stopId,
    required String boxCode,
    required bool isSelected,
  }) {
    return AppMapMarkerBitmapFactory.createStopMarker(
      context,
      stopId: stopId,
      boxCode: boxCode,
      isSelected: isSelected,
    );
  }
}
