import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_order_queue_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherOrderQueueResponseDto {
  const DispatcherOrderQueueResponseDto({
    this.restaurant,
    this.counts,
    this.boxes,
  });

  factory DispatcherOrderQueueResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherOrderQueueResponseDtoFromJson(json);

  final DispatcherOrderQueueRestaurantDto? restaurant;
  final DispatcherOrderQueueCountsDto? counts;
  final List<DispatcherOrderBoxDto>? boxes;
}

@JsonSerializable(createToJson: false)
class DispatcherOrderQueueRestaurantDto {
  const DispatcherOrderQueueRestaurantDto({
    this.id,
    this.nameAr,
    this.nameEn,
    this.role,
  });

  factory DispatcherOrderQueueRestaurantDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherOrderQueueRestaurantDtoFromJson(json);

  final String? id;
  final String? nameAr;
  final String? nameEn;
  final String? role;
}

@JsonSerializable(createToJson: false)
class DispatcherOrderQueueCountsDto {
  const DispatcherOrderQueueCountsDto({
    this.totalCount,
    this.pendingCount,
    this.assignedCount,
    this.inDeliveryCount,
    this.issuesCount,
  });

  factory DispatcherOrderQueueCountsDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherOrderQueueCountsDtoFromJson(json);

  final int? totalCount;
  final int? pendingCount;
  final int? assignedCount;
  final int? inDeliveryCount;
  final int? issuesCount;
}

@JsonSerializable(createToJson: false)
class DispatcherOrderBoxDto {
  const DispatcherOrderBoxDto({
    this.boxId,
    this.boxCode,
    this.zoneName,
    this.mealCount,
    this.mealCountLabel,
    this.deliveryTimeWindow,
    this.distanceKm,
    this.distanceText,
    this.status,
    this.priority,
    this.priorityBadgeText,
    this.suggestion,
  });

  factory DispatcherOrderBoxDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherOrderBoxDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? zoneName;
  final int? mealCount;
  final String? mealCountLabel;
  final String? deliveryTimeWindow;
  final double? distanceKm;
  final String? distanceText;
  final String? status;
  final String? priority;
  final String? priorityBadgeText;
  final DispatcherDriverSuggestionDto? suggestion;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverSuggestionDto {
  const DispatcherDriverSuggestionDto({
    this.driverId,
    this.driverName,
    this.avatarUrl,
    this.suggestionType,
    this.label,
  });

  factory DispatcherDriverSuggestionDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverSuggestionDtoFromJson(json);

  final String? driverId;
  final String? driverName;
  final String? avatarUrl;
  final String? suggestionType;
  final String? label;
}
