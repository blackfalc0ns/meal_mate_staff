import '../../domain/entities/dispatcher_driver_suggestion_entity.dart';
import '../../domain/entities/dispatcher_order_entity.dart';
import '../../domain/entities/dispatcher_order_priority.dart';
import '../../domain/entities/dispatcher_order_queue_entity.dart';
import '../../domain/entities/dispatcher_order_status.dart';
import '../models/response/dispatcher_order_queue_response_dto.dart';

extension DispatcherOrderQueueResponseDtoMapper
    on DispatcherOrderQueueResponseDto? {
  DispatcherOrderQueueEntity toEntity() {
    return DispatcherOrderQueueEntity(
      restaurant:
          this?.restaurant.toEntity() ??
          const DispatcherOrderQueueRestaurantEntity(
            id: '',
            nameAr: '',
            nameEn: '',
            role: '',
          ),
      counts:
          this?.counts.toEntity() ?? const DispatcherOrderQueueCountsEntity(),
      boxes: this?.boxes?.map((b) => b.toEntity()).toList() ?? const [],
    );
  }
}

extension DispatcherOrderQueueRestaurantDtoMapper
    on DispatcherOrderQueueRestaurantDto? {
  DispatcherOrderQueueRestaurantEntity toEntity() {
    return DispatcherOrderQueueRestaurantEntity(
      id: this?.id ?? '',
      nameAr: this?.nameAr ?? '',
      nameEn: this?.nameEn ?? '',
      role: this?.role ?? '',
    );
  }
}

extension DispatcherOrderQueueCountsDtoMapper
    on DispatcherOrderQueueCountsDto? {
  DispatcherOrderQueueCountsEntity toEntity() {
    return DispatcherOrderQueueCountsEntity(
      totalCount: this?.totalCount ?? 0,
      pendingCount: this?.pendingCount ?? 0,
      assignedCount: this?.assignedCount ?? 0,
      inDeliveryCount: this?.inDeliveryCount ?? 0,
      issuesCount: this?.issuesCount ?? 0,
    );
  }
}

extension DispatcherOrderBoxDtoMapper on DispatcherOrderBoxDto? {
  DispatcherOrderEntity toEntity() {
    return DispatcherOrderEntity(
      id: this?.boxId ?? '',
      boxCode: this?.boxCode ?? '',
      area: this?.zoneName ?? '',
      mealsCount: this?.mealCount ?? 0,
      mealCountLabel: this?.mealCountLabel ?? '',
      deliveryTimeWindow: this?.deliveryTimeWindow ?? '',
      distanceKm: this?.distanceKm ?? 0.0,
      distanceText: this?.distanceText ?? '',
      status: DispatcherOrderStatus.fromWire(this?.status),
      priority: DispatcherOrderPriority.fromWire(this?.priority),
      priorityBadgeText: this?.priorityBadgeText ?? '',
      suggestion: this?.suggestion?.toEntity(),
    );
  }
}

extension DispatcherDriverSuggestionDtoMapper
    on DispatcherDriverSuggestionDto? {
  DispatcherDriverSuggestionEntity? toEntity() {
    if (this == null) return null;
    return DispatcherDriverSuggestionEntity(
      driverId: this?.driverId ?? '',
      driverName: this?.driverName ?? '',
      avatarUrl: this?.avatarUrl,
      suggestionType: DispatcherDriverSuggestionType.fromWire(
        this?.suggestionType,
      ),
      label: this?.label ?? '',
    );
  }
}
