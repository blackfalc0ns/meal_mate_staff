import '../../domain/entities/dispatcher_driver_details_entity.dart';
import '../../domain/entities/dispatcher_driver_document_entity.dart';
import '../../domain/entities/dispatcher_driver_location_entity.dart';
import '../../domain/entities/dispatcher_driver_performance_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_driver_vehicle_entity.dart';
import '../models/response/dispatcher_driver_details_response_dto.dart';
import 'dispatcher_drivers_status_mapper.dart';

class DispatcherDriverDetailsMapper {
  const DispatcherDriverDetailsMapper._();

  static DispatcherDriverDocumentType _mapDocType(
    String? typeStr,
    String? nameStr,
  ) {
    final combined = '${typeStr ?? ''} ${nameStr ?? ''}'.toLowerCase();
    if (combined.contains('license') ||
        combined.contains('قيادة') ||
        combined.contains('رخصة')) {
      return DispatcherDriverDocumentType.drivingLicense;
    }
    if (combined.contains('registration') ||
        combined.contains('مركبة') ||
        combined.contains('دفتر')) {
      return DispatcherDriverDocumentType.vehicleRegistration;
    }
    if (combined.contains('insurance') || combined.contains('تأمين')) {
      return DispatcherDriverDocumentType.insurance;
    }
    return DispatcherDriverDocumentType.drivingLicense;
  }

  static DispatcherDriverDetailsEntity toEntity(
    DispatcherDriverDetailsResponseDto dto, {
    String? baseUrl,
    String? fallbackDriverId,
  }) {
    final profile = dto.driver;
    final driverId = profile?.driverId ?? fallbackDriverId ?? '';
    final phone = profile?.phoneNumber?.trim();
    final operationalStatus = DispatcherDriverStatusType.fromApi(
      profile?.operationalStatus,
    );
    final isOnline =
        operationalStatus != DispatcherDriverStatusType.unavailable &&
        operationalStatus != DispatcherDriverStatusType.unknown;

    // Vehicle
    DispatcherDriverVehicleEntity? vehicle;
    if (dto.vehicle != null) {
      vehicle = DispatcherDriverVehicleEntity(
        model: dto.vehicle?.vehicleModel ?? '',
        colorName: dto.vehicle?.color ?? '',
        plateNumber: dto.vehicle?.vehiclePlate ?? '',
        vehicleType: dto.vehicle?.vehicleType ?? '',
      );
    }

    // Location
    DispatcherDriverLocationEntity? location;
    if (dto.currentLocation != null) {
      DateTime? locationDate;
      if (dto.currentLocation?.updatedAtUtc != null) {
        locationDate = DateTime.tryParse(
          dto.currentLocation!.updatedAtUtc!,
        )?.toUtc();
      }
      final minutesAgo = locationDate != null
          ? DateTime.now()
                .toUtc()
                .difference(locationDate)
                .inMinutes
                .clamp(0, 9999)
          : 0;

      location = DispatcherDriverLocationEntity(
        areaName: dto.currentLocation?.address ?? '',
        updatedMinutesAgo: minutesAgo,
        latitude: dto.currentLocation?.latitude,
        longitude: dto.currentLocation?.longitude,
        updatedAtUtc: locationDate,
      );
    }

    // Performance
    DispatcherDriverPerformanceEntity? performance;
    if (dto.performance != null) {
      performance = DispatcherDriverPerformanceEntity(
        totalOrders: dto.performance?.totalDeliveries ?? 0,
        averageRating: profile?.rating ?? 0.0,
        commitmentRatePercent: dto.performance?.acceptanceRate?.round() ?? 0,
        violationsCount: 0,
        acceptanceRate: dto.performance?.acceptanceRate,
        onTimeRate: dto.performance?.onTimeRate,
        averageDeliveryMinutes: dto.performance?.averageDeliveryMinutes,
        totalDeliveries: dto.performance?.totalDeliveries,
      );
    }

    // Documents
    final documents =
        dto.documents?.map((d) {
          final status = DispatcherDriverDocumentStatus.fromApi(d.status);
          final isValid =
              status == DispatcherDriverDocumentStatus.valid ||
              status == DispatcherDriverDocumentStatus.expiringSoon;
          return DispatcherDriverDocumentEntity(
            type: _mapDocType(d.documentType, d.documentName),
            isValid: isValid,
            validUntil: d.expiryDate,
            documentType: d.documentType,
            documentName: d.documentName,
            status: status,
            documentUrl: d.documentUrl,
          );
        }).toList() ??
        const [];

    return DispatcherDriverDetailsEntity(
      id: driverId,
      name: profile?.fullName ?? '',
      code: profile?.driverCode ?? '',
      avatarUrl: DispatcherDriversStatusMapper.resolveAvatarUrl(
        profile?.avatarStorageKey,
        baseUrl: baseUrl,
      ),
      rating: profile?.rating,
      reviewCount: profile?.ratingsCount,
      isAvailable: profile?.isAvailable ?? false,
      operationalStatus: operationalStatus,
      isOnline: isOnline,
      phoneNumber: (phone != null && phone.isNotEmpty) ? phone : null,
      totalOrdersToday: dto.today?.completedDeliveries ?? 0,
      activeOrdersToday: dto.today?.activeDeliveries ?? 0,
      cashCollectedToday: dto.today?.cashCollected,
      distanceKmToday: dto.today?.distanceKm,
      workTimeMinutesToday: dto.performance?.averageDeliveryMinutes ?? 0,
      vehicle: vehicle,
      location: location,
      performance: performance,
      documents: documents,
    );
  }
}

extension DispatcherDriverDetailsResponseDtoMapper
    on DispatcherDriverDetailsResponseDto {
  DispatcherDriverDetailsEntity toEntity({
    String? baseUrl,
    String? fallbackDriverId,
  }) => DispatcherDriverDetailsMapper.toEntity(
    this,
    baseUrl: baseUrl,
    fallbackDriverId: fallbackDriverId,
  );
}
