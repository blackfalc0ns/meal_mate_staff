import '../entities/dispatcher_metric_entity.dart';
import '../entities/dispatcher_metric_type.dart';
import '../entities/dispatcher_order_entity.dart';
import '../entities/dispatcher_order_priority.dart';

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
      area: 'منطقة السالمية',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 8,
      distanceKm: '6.2',
      suggestedDriverName: 'أحمد',
      isLeastLoaded: false,
    ),
    DispatcherOrderEntity(
      id: '2',
      boxCode: '#BX-1257',
      priority: DispatcherOrderPriority.urgent,
      area: 'منطقة حولي',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 5,
      distanceKm: '4.2',
      suggestedDriverName: 'محمد',
      isLeastLoaded: true,
    ),
    DispatcherOrderEntity(
      id: '3',
      boxCode: '#BX-1258',
      priority: DispatcherOrderPriority.highPriority,
      area: 'منطقة الفحيحيل',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 6,
      distanceKm: '7.2',
      suggestedDriverName: 'سالم',
      isLeastLoaded: false,
    ),
    DispatcherOrderEntity(
      id: '4',
      boxCode: '#BX-1259',
      priority: DispatcherOrderPriority.normal,
      area: 'منطقة الجهراء',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 4,
      distanceKm: '3.2',
      suggestedDriverName: 'عبد الله',
      isLeastLoaded: true,
    ),
    DispatcherOrderEntity(
      id: '5',
      boxCode: '#BX-1260',
      priority: DispatcherOrderPriority.newOrder,
      area: 'منطقة المنقف',
      deliveryTimeWindow: '09:30-10:30 ص',
      mealsCount: 2,
      distanceKm: '3.2',
      suggestedDriverName: 'فهد',
      isLeastLoaded: false,
    ),
  ];
}
