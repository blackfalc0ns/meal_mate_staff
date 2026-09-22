// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_order_queue_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherOrderQueueResponseDto _$DispatcherOrderQueueResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherOrderQueueResponseDto(
  restaurant: json['restaurant'] == null
      ? null
      : DispatcherOrderQueueRestaurantDto.fromJson(
          json['restaurant'] as Map<String, dynamic>,
        ),
  counts: json['counts'] == null
      ? null
      : DispatcherOrderQueueCountsDto.fromJson(
          json['counts'] as Map<String, dynamic>,
        ),
  boxes: (json['boxes'] as List<dynamic>?)
      ?.map((e) => DispatcherOrderBoxDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

DispatcherOrderQueueRestaurantDto _$DispatcherOrderQueueRestaurantDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherOrderQueueRestaurantDto(
  id: json['id'] as String?,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  role: json['role'] as String?,
);

DispatcherOrderQueueCountsDto _$DispatcherOrderQueueCountsDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherOrderQueueCountsDto(
  totalCount: (json['totalCount'] as num?)?.toInt(),
  pendingCount: (json['pendingCount'] as num?)?.toInt(),
  assignedCount: (json['assignedCount'] as num?)?.toInt(),
  inDeliveryCount: (json['inDeliveryCount'] as num?)?.toInt(),
  issuesCount: (json['issuesCount'] as num?)?.toInt(),
);

DispatcherOrderBoxDto _$DispatcherOrderBoxDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherOrderBoxDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  zoneName: json['zoneName'] as String?,
  mealCount: (json['mealCount'] as num?)?.toInt(),
  mealCountLabel: json['mealCountLabel'] as String?,
  deliveryTimeWindow: json['deliveryTimeWindow'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  distanceText: json['distanceText'] as String?,
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  priorityBadgeText: json['priorityBadgeText'] as String?,
  suggestion: json['suggestion'] == null
      ? null
      : DispatcherDriverSuggestionDto.fromJson(
          json['suggestion'] as Map<String, dynamic>,
        ),
);

DispatcherDriverSuggestionDto _$DispatcherDriverSuggestionDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverSuggestionDto(
  driverId: json['driverId'] as String?,
  driverName: json['driverName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  suggestionType: json['suggestionType'] as String?,
  label: json['label'] as String?,
);
