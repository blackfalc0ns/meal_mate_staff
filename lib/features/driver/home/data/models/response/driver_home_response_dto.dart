import 'package:json_annotation/json_annotation.dart';

part 'driver_home_response_dto.g.dart';

@JsonSerializable()
class DriverHomeResponseDto {
  const DriverHomeResponseDto({
    this.driverId,
    this.driverName,
    this.driverCode,
    this.profileImageUrl,
    this.shiftStatus,
    this.isAvailable,
    this.currentStatusText,
    this.nextLocationText,
    this.targetProgress,
    this.currentDeliveryTask,
    this.todaySummary,
    this.dailyPerformance,
    this.activeSession,
    this.unreadNotificationsCount,
  });

  factory DriverHomeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverHomeResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverHomeResponseDtoToJson(this);

  final String? driverId;
  final String? driverName;
  final String? driverCode;
  final String? profileImageUrl;
  final String? shiftStatus;
  final bool? isAvailable;
  final String? currentStatusText;
  final String? nextLocationText;
  final DriverHomeTargetProgressResponseDto? targetProgress;
  final DriverHomeCurrentDeliveryTaskResponseDto? currentDeliveryTask;
  final DriverHomeTodaySummaryResponseDto? todaySummary;
  final DriverHomeDailyPerformanceResponseDto? dailyPerformance;
  final DriverHomeActiveSessionResponseDto? activeSession;
  final int? unreadNotificationsCount;
}

@JsonSerializable()
class DriverHomeTargetProgressResponseDto {
  const DriverHomeTargetProgressResponseDto({
    this.targetPercentage,
    this.targetText,
    this.completedBoxes,
    this.totalBoxes,
  });

  factory DriverHomeTargetProgressResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverHomeTargetProgressResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DriverHomeTargetProgressResponseDtoToJson(this);

  final double? targetPercentage;
  final String? targetText;
  final int? completedBoxes;
  final int? totalBoxes;
}

@JsonSerializable()
class DriverHomeCurrentDeliveryTaskResponseDto {
  const DriverHomeCurrentDeliveryTaskResponseDto({
    this.boxId,
    this.boxCode,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.destinationLatitude,
    this.destinationLongitude,
    this.mealsCount,
    this.mealsSummary,
    this.deliveryTimeSlot,
    this.status,
    this.deliveryNotes,
  });

  factory DriverHomeCurrentDeliveryTaskResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverHomeCurrentDeliveryTaskResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DriverHomeCurrentDeliveryTaskResponseDtoToJson(this);

  final String? boxId;
  final String? boxCode;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final int? mealsCount;
  final String? mealsSummary;
  final String? deliveryTimeSlot;
  final String? status;
  final String? deliveryNotes;
}

@JsonSerializable()
class DriverHomeTodaySummaryResponseDto {
  const DriverHomeTodaySummaryResponseDto({
    this.completedTripsCount,
    this.completedBoxesCount,
    this.totalDeliveredBoxesCount,
    this.failedDeliveriesCount,
    this.collectedCashAmount,
    this.totalEarnings,
    this.currency,
  });

  factory DriverHomeTodaySummaryResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverHomeTodaySummaryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DriverHomeTodaySummaryResponseDtoToJson(this);

  final int? completedTripsCount;
  final int? completedBoxesCount;
  final int? totalDeliveredBoxesCount;
  final int? failedDeliveriesCount;
  final double? collectedCashAmount;
  final double? totalEarnings;
  final String? currency;
}

@JsonSerializable()
class DriverHomeDailyPerformanceResponseDto {
  const DriverHomeDailyPerformanceResponseDto({
    this.deliveredOrdersCount,
    this.onTimeDeliveryRate,
    this.customerRating,
    this.acceptanceRate,
  });

  factory DriverHomeDailyPerformanceResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverHomeDailyPerformanceResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DriverHomeDailyPerformanceResponseDtoToJson(this);

  final int? deliveredOrdersCount;
  final double? onTimeDeliveryRate;
  final double? customerRating;
  final double? acceptanceRate;
}

@JsonSerializable()
class DriverHomeActiveSessionResponseDto {
  const DriverHomeActiveSessionResponseDto({
    this.shiftId,
    this.startedAtUtc,
    this.durationMinutes,
    this.status,
  });

  factory DriverHomeActiveSessionResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverHomeActiveSessionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DriverHomeActiveSessionResponseDtoToJson(this);

  final String? shiftId;
  final String? startedAtUtc;
  final int? durationMinutes;
  final String? status;
}
