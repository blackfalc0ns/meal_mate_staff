import 'dispatcher_driver_status.dart';

class DispatcherDriverEntity {
  const DispatcherDriverEntity({
    required this.driverId,
    required this.driverCode,
    required this.fullName,
    this.avatarUrl,
    required this.rating,
    required this.status,
    this.statusText,
    this.statusDotColor,
    required this.isAvailableForSelection,
    required this.activeOrdersCount,
    this.activeOrdersText,
    required this.completedOrdersTodayCount,
    this.completedOrdersText,
    required this.distanceKm,
    this.distanceText,
    required this.currentZoneName,
    this.currentZoneKey,
  });

  final String driverId;
  final String driverCode;
  final String fullName;
  final String? avatarUrl;
  final double rating;
  final DispatcherDriverStatus status;
  final String? statusText;
  final String? statusDotColor;
  final bool isAvailableForSelection;
  final int activeOrdersCount;
  final String? activeOrdersText;
  final int completedOrdersTodayCount;
  final String? completedOrdersText;
  final double distanceKm;
  final String? distanceText;
  final String currentZoneName;
  final String? currentZoneKey;

  // Legacy/convenience getters
  String get id => driverId;
  String get name => fullName;
  String get area => currentZoneName;
  int get currentOrdersCount => activeOrdersCount;
  bool get isAvailable => isAvailableForSelection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverEntity &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          driverCode == other.driverCode &&
          fullName == other.fullName &&
          avatarUrl == other.avatarUrl &&
          rating == other.rating &&
          status == other.status &&
          statusText == other.statusText &&
          statusDotColor == other.statusDotColor &&
          isAvailableForSelection == other.isAvailableForSelection &&
          activeOrdersCount == other.activeOrdersCount &&
          activeOrdersText == other.activeOrdersText &&
          completedOrdersTodayCount == other.completedOrdersTodayCount &&
          completedOrdersText == other.completedOrdersText &&
          distanceKm == other.distanceKm &&
          distanceText == other.distanceText &&
          currentZoneName == other.currentZoneName &&
          currentZoneKey == other.currentZoneKey;

  @override
  int get hashCode =>
      driverId.hashCode ^
      driverCode.hashCode ^
      fullName.hashCode ^
      avatarUrl.hashCode ^
      rating.hashCode ^
      status.hashCode ^
      statusText.hashCode ^
      statusDotColor.hashCode ^
      isAvailableForSelection.hashCode ^
      activeOrdersCount.hashCode ^
      activeOrdersText.hashCode ^
      completedOrdersTodayCount.hashCode ^
      completedOrdersText.hashCode ^
      distanceKm.hashCode ^
      distanceText.hashCode ^
      currentZoneName.hashCode ^
      currentZoneKey.hashCode;
}
