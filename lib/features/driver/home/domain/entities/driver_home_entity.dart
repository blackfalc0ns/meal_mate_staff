enum DriverShiftStatus {
  active,
  inactive;

  bool get isActive => this == DriverShiftStatus.active;
  bool get isInactive => this == DriverShiftStatus.inactive;
}

class DriverHomeEntity {
  const DriverHomeEntity({
    required this.driverId,
    required this.driverName,
    required this.driverCode,
    this.profileImageUrl,
    required this.shiftStatus,
    required this.isAvailable,
    required this.currentStatusText,
    this.nextLocationText,
    this.targetProgress,
    this.currentDeliveryTask,
    this.todaySummary,
    this.dailyPerformance,
    this.activeSession,
    this.unreadNotificationsCount = 0,
  });

  final String driverId;
  final String driverName;
  final String driverCode;
  final String? profileImageUrl;
  final DriverShiftStatus shiftStatus;
  final bool isAvailable;
  final String currentStatusText;
  final String? nextLocationText;
  final DriverHomeTargetProgressEntity? targetProgress;
  final DriverHomeCurrentDeliveryTaskEntity? currentDeliveryTask;
  final DriverHomeTodaySummaryEntity? todaySummary;
  final DriverHomeDailyPerformanceEntity? dailyPerformance;
  final DriverHomeActiveSessionEntity? activeSession;
  final int unreadNotificationsCount;

  bool get isActive => shiftStatus.isActive;
  bool get isInactive => shiftStatus.isInactive;
  bool get hasActiveDelivery => currentDeliveryTask != null;
  bool get isBusy => isActive && (!isAvailable || hasActiveDelivery);
  bool get isAvailableAndIdle => isActive && isAvailable && !hasActiveDelivery;
}

class DriverHomeTargetProgressEntity {
  const DriverHomeTargetProgressEntity({
    required this.targetPercentage,
    required this.targetText,
    required this.completedBoxes,
    required this.totalBoxes,
  });

  final double targetPercentage;
  final String targetText;
  final int completedBoxes;
  final int totalBoxes;
}

class DriverHomeCurrentDeliveryTaskEntity {
  const DriverHomeCurrentDeliveryTaskEntity({
    required this.boxId,
    required this.boxCode,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.destinationLatitude,
    this.destinationLongitude,
    required this.mealsCount,
    required this.mealsSummary,
    required this.deliveryTimeSlot,
    required this.status,
    required this.deliveryNotes,
  });

  final String boxId;
  final String boxCode;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final int mealsCount;
  final String mealsSummary;
  final String deliveryTimeSlot;
  final String status;
  final String deliveryNotes;
}

class DriverHomeTodaySummaryEntity {
  const DriverHomeTodaySummaryEntity({
    required this.completedTripsCount,
    required this.completedBoxesCount,
    required this.totalDeliveredBoxesCount,
    required this.failedDeliveriesCount,
    required this.collectedCashAmount,
    required this.totalEarnings,
    required this.currency,
  });

  final int completedTripsCount;
  final int completedBoxesCount;
  final int totalDeliveredBoxesCount;
  final int failedDeliveriesCount;
  final double collectedCashAmount;
  final double totalEarnings;
  final String currency;
}

class DriverHomeDailyPerformanceEntity {
  const DriverHomeDailyPerformanceEntity({
    required this.deliveredOrdersCount,
    required this.onTimeDeliveryRate,
    required this.customerRating,
    required this.acceptanceRate,
  });

  final int deliveredOrdersCount;
  final double onTimeDeliveryRate;
  final double customerRating;
  final double acceptanceRate;
}

class DriverHomeActiveSessionEntity {
  const DriverHomeActiveSessionEntity({
    required this.shiftId,
    this.startedAtUtc,
    required this.durationMinutes,
    required this.status,
  });

  final String shiftId;
  final DateTime? startedAtUtc;
  final int durationMinutes;
  final String status;
}
