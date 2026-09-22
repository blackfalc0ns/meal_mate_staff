import '../entities/dispatcher_driver_suggestion_entity.dart';
import '../entities/dispatcher_metric_entity.dart';
import '../entities/dispatcher_metric_type.dart';
import '../entities/dispatcher_order_entity.dart';
import '../entities/dispatcher_order_priority.dart';
import '../entities/dispatcher_order_status.dart';

class DispatcherFakeData {
  const DispatcherFakeData._();

  static const List<DispatcherMetricEntity> metrics = [
    DispatcherMetricEntity(
      type: DispatcherMetricType.pendingAssignment,
      count: 23,
    ),
    DispatcherMetricEntity(type: DispatcherMetricType.assigned, count: 37),
    DispatcherMetricEntity(type: DispatcherMetricType.inDelivery, count: 58),
    DispatcherMetricEntity(type: DispatcherMetricType.problems, count: 2),
  ];

  static const List<DispatcherOrderEntity> orders = [
    DispatcherOrderEntity(
      id: '1',
      boxCode: '#BX-1256',
      priority: DispatcherOrderPriority.newOrder,
      status: DispatcherOrderStatus.pending,
      area: 'منطقة السالمية',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 8,
      distanceKm: 6.2,
      distanceText: '6.2',
      suggestion: DispatcherDriverSuggestionEntity(
        driverId: '1',
        driverName: 'أحمد',
        suggestionType: DispatcherDriverSuggestionType.nearest,
        label: 'الأقرب: أحمد',
      ),
    ),
    DispatcherOrderEntity(
      id: '2',
      boxCode: '#BX-1257',
      priority: DispatcherOrderPriority.urgent,
      status: DispatcherOrderStatus.pending,
      area: 'منطقة حولي',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 5,
      distanceKm: 4.2,
      distanceText: '4.2',
      suggestion: DispatcherDriverSuggestionEntity(
        driverId: '2',
        driverName: 'محمد',
        suggestionType: DispatcherDriverSuggestionType.leastLoaded,
        label: 'الأقل حملاً: محمد',
      ),
    ),
    DispatcherOrderEntity(
      id: '3',
      boxCode: '#BX-1258',
      priority: DispatcherOrderPriority.highPriority,
      status: DispatcherOrderStatus.pending,
      area: 'منطقة الفحيحيل',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 6,
      distanceKm: 7.2,
      distanceText: '7.2',
      suggestion: DispatcherDriverSuggestionEntity(
        driverId: '3',
        driverName: 'سالم',
        suggestionType: DispatcherDriverSuggestionType.nearest,
        label: 'الأقرب: سالم',
      ),
    ),
    DispatcherOrderEntity(
      id: '4',
      boxCode: '#BX-1259',
      priority: DispatcherOrderPriority.normal,
      status: DispatcherOrderStatus.pending,
      area: 'منطقة الجهراء',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 4,
      distanceKm: 3.2,
      distanceText: '3.2',
      suggestion: DispatcherDriverSuggestionEntity(
        driverId: '4',
        driverName: 'عبد الله',
        suggestionType: DispatcherDriverSuggestionType.leastLoaded,
        label: 'الأقل حملاً: عبد الله',
      ),
    ),
    DispatcherOrderEntity(
      id: '5',
      boxCode: '#BX-1260',
      priority: DispatcherOrderPriority.newOrder,
      status: DispatcherOrderStatus.pending,
      area: 'منطقة المنقف',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 2,
      distanceKm: 3.2,
      distanceText: '3.2',
      suggestion: DispatcherDriverSuggestionEntity(
        driverId: '5',
        driverName: 'فهد',
        suggestionType: DispatcherDriverSuggestionType.nearest,
        label: 'الأقرب: فهد',
      ),
    ),
  ];
}
