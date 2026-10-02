import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract interface class DriverLocationService {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<bool> checkAndRequestPermission();
  Future<Position?> getCurrentPosition();
  Stream<Position> getPositionStream({
    int intervalSeconds = 3,
    int distanceFilterMeters = 3,
  });
}

class DriverLocationServiceImpl implements DriverLocationService {
  DriverLocationServiceImpl();

  void _log(String message, {Object? error}) {
    developer.log(message, name: 'DriverLocationService', error: error);
    debugPrint('[DriverLocationService] $message');
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  @override
  Future<bool> checkAndRequestPermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _log('Location service is disabled on device');
      return false;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      _log('Requesting location permission from user...');
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        _log('Location permission was DENIED by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log('Location permission is PERMANENTLY DENIED');
      return false;
    }

    final granted = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    _log('Location permission check: ${granted ? "GRANTED" : "DENIED"} ($permission)');
    return granted;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (isValidCoordinate(position.latitude, position.longitude)) {
        return position;
      }
      return null;
    } catch (e) {
      _log('Error getting current position: $e', error: e);
      return null;
    }
  }

  @override
  Stream<Position> getPositionStream({
    int intervalSeconds = 3,
    int distanceFilterMeters = 3,
  }) {
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        intervalDuration: Duration(seconds: intervalSeconds),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'تطبيق السائق — البث الحي للموقع',
          notificationText: 'جاري إرسال الموقع للديسباتشر أثناء القيادة والتسليم النشط',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: distanceFilterMeters,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .where((pos) => isValidCoordinate(pos.latitude, pos.longitude));
  }

  static bool isValidCoordinate(double lat, double lng) {
    return !(lat == 0.0 && lng == 0.0) &&
        lat.isFinite &&
        lng.isFinite &&
        lat >= -90.0 &&
        lat <= 90.0 &&
        lng >= -180.0 &&
        lng <= 180.0;
  }
}
