import 'dispatcher_driver_document_entity.dart';
import 'dispatcher_driver_location_entity.dart';
import 'dispatcher_driver_performance_entity.dart';
import 'dispatcher_driver_vehicle_entity.dart';

class DispatcherDriverDetailsEntity {
  const DispatcherDriverDetailsEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.isOnline,
    required this.phoneNumber,
    required this.totalOrdersToday,
    required this.workTimeMinutesToday,
    required this.distanceKmToday,
    required this.activeOrdersToday,
    required this.vehicle,
    required this.location,
    required this.performance,
    required this.documents,
  });

  final String id;
  final String name;
  final String code;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isOnline;
  final String phoneNumber;
  final int totalOrdersToday;
  final int workTimeMinutesToday;
  final double distanceKmToday;
  final int activeOrdersToday;
  final DispatcherDriverVehicleEntity vehicle;
  final DispatcherDriverLocationEntity location;
  final DispatcherDriverPerformanceEntity performance;
  final List<DispatcherDriverDocumentEntity> documents;

  DispatcherDriverDetailsEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? avatarUrl,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    bool? isOnline,
    String? phoneNumber,
    int? totalOrdersToday,
    int? workTimeMinutesToday,
    double? distanceKmToday,
    int? activeOrdersToday,
    DispatcherDriverVehicleEntity? vehicle,
    DispatcherDriverLocationEntity? location,
    DispatcherDriverPerformanceEntity? performance,
    List<DispatcherDriverDocumentEntity>? documents,
  }) {
    return DispatcherDriverDetailsEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      totalOrdersToday: totalOrdersToday ?? this.totalOrdersToday,
      workTimeMinutesToday: workTimeMinutesToday ?? this.workTimeMinutesToday,
      distanceKmToday: distanceKmToday ?? this.distanceKmToday,
      activeOrdersToday: activeOrdersToday ?? this.activeOrdersToday,
      vehicle: vehicle ?? this.vehicle,
      location: location ?? this.location,
      performance: performance ?? this.performance,
      documents: documents ?? this.documents,
    );
  }
}
