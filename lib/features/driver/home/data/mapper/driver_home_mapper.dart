import '../../domain/entities/driver_home_entity.dart';
import '../models/response/driver_home_response_dto.dart';

extension DriverHomeResponseDtoMapper on DriverHomeResponseDto {
  DriverHomeEntity toEntity() {
    return DriverHomeEntity(
      driverId: driverId ?? '',
      driverName: driverName ?? '',
      driverCode: driverCode ?? '',
      profileImageUrl: profileImageUrl,
      shiftStatus: _parseShiftStatus(shiftStatus),
      isAvailable: isAvailable ?? false,
      currentStatusText: currentStatusText ?? '',
      nextLocationText: nextLocationText,
      targetProgress: targetProgress?.toEntity(),
      currentDeliveryTask: currentDeliveryTask?.toEntity(),
      todaySummary: todaySummary?.toEntity(),
      dailyPerformance: dailyPerformance?.toEntity(),
      activeSession: activeSession?.toEntity(),
      unreadNotificationsCount: unreadNotificationsCount ?? 0,
    );
  }

  static DriverShiftStatus _parseShiftStatus(String? rawStatus) {
    if (rawStatus == null) return DriverShiftStatus.inactive;
    final normalized = rawStatus.trim().toLowerCase();
    if (normalized == 'active') {
      return DriverShiftStatus.active;
    }
    // "inactive", "offline", null, or unknown values safely fall back to inactive
    return DriverShiftStatus.inactive;
  }
}

extension DriverHomeTargetProgressResponseDtoMapper
    on DriverHomeTargetProgressResponseDto {
  DriverHomeTargetProgressEntity toEntity() {
    return DriverHomeTargetProgressEntity(
      targetPercentage: targetPercentage ?? 0.0,
      targetText: targetText ?? '',
      completedBoxes: completedBoxes ?? 0,
      totalBoxes: totalBoxes ?? 0,
    );
  }
}

extension DriverHomeCurrentDeliveryTaskResponseDtoMapper
    on DriverHomeCurrentDeliveryTaskResponseDto {
  DriverHomeCurrentDeliveryTaskEntity toEntity() {
    return DriverHomeCurrentDeliveryTaskEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      customerName: customerName ?? '',
      customerPhone: customerPhone ?? '',
      deliveryAddress: deliveryAddress ?? '',
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      mealsCount: mealsCount ?? 0,
      mealsSummary: mealsSummary ?? '',
      deliveryTimeSlot: deliveryTimeSlot ?? '',
      status: status ?? '',
      deliveryNotes: deliveryNotes ?? '',
    );
  }
}

extension DriverHomeTodaySummaryResponseDtoMapper
    on DriverHomeTodaySummaryResponseDto {
  DriverHomeTodaySummaryEntity toEntity() {
    return DriverHomeTodaySummaryEntity(
      completedTripsCount: completedTripsCount ?? 0,
      completedBoxesCount: completedBoxesCount ?? 0,
      totalDeliveredBoxesCount: totalDeliveredBoxesCount ?? 0,
      failedDeliveriesCount: failedDeliveriesCount ?? 0,
      collectedCashAmount: collectedCashAmount ?? 0.0,
      totalEarnings: totalEarnings ?? 0.0,
      currency: currency ?? '',
    );
  }
}

extension DriverHomeDailyPerformanceResponseDtoMapper
    on DriverHomeDailyPerformanceResponseDto {
  DriverHomeDailyPerformanceEntity toEntity() {
    return DriverHomeDailyPerformanceEntity(
      deliveredOrdersCount: deliveredOrdersCount ?? 0,
      onTimeDeliveryRate: onTimeDeliveryRate ?? 0.0,
      customerRating: customerRating ?? 0.0,
      acceptanceRate: acceptanceRate ?? 0.0,
    );
  }
}

extension DriverHomeActiveSessionResponseDtoMapper
    on DriverHomeActiveSessionResponseDto {
  DriverHomeActiveSessionEntity toEntity() {
    DateTime? parsedDate;
    if (startedAtUtc != null && startedAtUtc!.isNotEmpty) {
      parsedDate = DateTime.tryParse(startedAtUtc!)?.toUtc();
    }
    return DriverHomeActiveSessionEntity(
      shiftId: shiftId ?? '',
      startedAtUtc: parsedDate,
      durationMinutes: durationMinutes ?? 0,
      status: status ?? '',
    );
  }
}
