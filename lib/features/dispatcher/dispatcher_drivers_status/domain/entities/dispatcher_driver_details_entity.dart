import 'dispatcher_driver_document_entity.dart';
import 'dispatcher_driver_location_entity.dart';
import 'dispatcher_driver_performance_entity.dart';
import 'dispatcher_driver_status_type.dart';
import 'dispatcher_driver_vehicle_entity.dart';

class DispatcherDriverDetailsEntity {
  const DispatcherDriverDetailsEntity({
    String? id,
    String? driverId,
    required this.name,
    required this.code,
    this.avatarUrl,
    this.rating,
    this.reviewCount,
    this.isAvailable = true,
    this.operationalStatus = DispatcherDriverStatusType.available,
    this.isOnline = true,
    this.phoneNumber,
    this.totalOrdersToday = 0,
    this.workTimeMinutesToday = 0,
    this.distanceKmToday,
    this.activeOrdersToday = 0,
    this.cashCollectedToday,
    this.vehicle,
    this.location,
    this.performance,
    this.documents = const [],
  }) : id = id ?? driverId ?? '';

  final String id;
  String get driverId => id;
  final String name;
  final String code;
  final String? avatarUrl;
  final double? rating;
  final int? reviewCount;
  final bool isAvailable;
  final DispatcherDriverStatusType operationalStatus;
  final bool isOnline;
  final String? phoneNumber;
  final int totalOrdersToday;
  final int workTimeMinutesToday;
  final double? distanceKmToday;
  final int activeOrdersToday;
  final double? cashCollectedToday;
  final DispatcherDriverVehicleEntity? vehicle;
  final DispatcherDriverLocationEntity? location;
  final DispatcherDriverPerformanceEntity? performance;
  final List<DispatcherDriverDocumentEntity> documents;

  DispatcherDriverDetailsEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    double? rating,
    bool clearRating = false,
    int? reviewCount,
    bool clearReviewCount = false,
    bool? isAvailable,
    DispatcherDriverStatusType? operationalStatus,
    bool? isOnline,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    int? totalOrdersToday,
    int? workTimeMinutesToday,
    double? distanceKmToday,
    bool clearDistanceKmToday = false,
    int? activeOrdersToday,
    double? cashCollectedToday,
    bool clearCashCollectedToday = false,
    DispatcherDriverVehicleEntity? vehicle,
    bool clearVehicle = false,
    DispatcherDriverLocationEntity? location,
    bool clearLocation = false,
    DispatcherDriverPerformanceEntity? performance,
    bool clearPerformance = false,
    List<DispatcherDriverDocumentEntity>? documents,
  }) {
    return DispatcherDriverDetailsEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      rating: clearRating ? null : (rating ?? this.rating),
      reviewCount: clearReviewCount ? null : (reviewCount ?? this.reviewCount),
      isAvailable: isAvailable ?? this.isAvailable,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      isOnline: isOnline ?? this.isOnline,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      totalOrdersToday: totalOrdersToday ?? this.totalOrdersToday,
      workTimeMinutesToday: workTimeMinutesToday ?? this.workTimeMinutesToday,
      distanceKmToday: clearDistanceKmToday
          ? null
          : (distanceKmToday ?? this.distanceKmToday),
      activeOrdersToday: activeOrdersToday ?? this.activeOrdersToday,
      cashCollectedToday: clearCashCollectedToday
          ? null
          : (cashCollectedToday ?? this.cashCollectedToday),
      vehicle: clearVehicle ? null : (vehicle ?? this.vehicle),
      location: clearLocation ? null : (location ?? this.location),
      performance: clearPerformance ? null : (performance ?? this.performance),
      documents: documents ?? this.documents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverDetailsEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          code == other.code &&
          avatarUrl == other.avatarUrl &&
          rating == other.rating &&
          reviewCount == other.reviewCount &&
          isAvailable == other.isAvailable &&
          operationalStatus == other.operationalStatus &&
          isOnline == other.isOnline &&
          phoneNumber == other.phoneNumber &&
          totalOrdersToday == other.totalOrdersToday &&
          workTimeMinutesToday == other.workTimeMinutesToday &&
          distanceKmToday == other.distanceKmToday &&
          activeOrdersToday == other.activeOrdersToday &&
          cashCollectedToday == other.cashCollectedToday &&
          vehicle == other.vehicle &&
          location == other.location &&
          performance == other.performance;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    avatarUrl,
    rating,
    reviewCount,
    isAvailable,
    operationalStatus,
    isOnline,
    phoneNumber,
    totalOrdersToday,
    activeOrdersToday,
  );
}
