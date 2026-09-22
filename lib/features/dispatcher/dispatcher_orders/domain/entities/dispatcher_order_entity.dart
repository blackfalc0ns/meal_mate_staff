import 'dispatcher_driver_suggestion_entity.dart';
import 'dispatcher_order_priority.dart';
import 'dispatcher_order_status.dart';

class DispatcherOrderEntity {
  const DispatcherOrderEntity({
    required this.id,
    required this.boxCode,
    required this.priority,
    this.status = DispatcherOrderStatus.pending,
    required this.area,
    required this.deliveryTimeWindow,
    required this.mealsCount,
    required this.distanceKm,
    this.distanceText = '',
    this.mealCountLabel = '',
    this.priorityBadgeText = '',
    this.suggestion,
  });

  final String id;
  final String boxCode;
  final DispatcherOrderPriority priority;
  final DispatcherOrderStatus status;
  final String area;
  final String deliveryTimeWindow;
  final int mealsCount;
  final double distanceKm;
  final String distanceText;
  final String mealCountLabel;
  final String priorityBadgeText;
  final DispatcherDriverSuggestionEntity? suggestion;

  // Compatibility helpers
  String get boxId => id;
  String get zoneName => area;
  int get mealCount => mealsCount;
  String get suggestedDriverName => suggestion?.driverName ?? '';
  String? get suggestedDriverAvatarUrl => suggestion?.avatarUrl;
  bool get isLeastLoaded =>
      suggestion?.suggestionType == DispatcherDriverSuggestionType.leastLoaded;
}
