import '../../../../../core/constants/assets.dart';
import '../../domain/entities/driver_active_home_entity.dart';
import '../../domain/entities/driver_current_order_entity.dart';
import '../../domain/entities/driver_daily_goal_entity.dart';
import '../../domain/entities/driver_daily_performance_entity.dart';
import '../../domain/entities/driver_daily_summary_entity.dart';
import '../../domain/entities/driver_start_work_entity.dart';
import '../../domain/entities/driver_start_work_metric_entity.dart';
import '../../domain/entities/driver_start_work_requirement_entity.dart';
import 'driver_home_datasource.dart';

class DriverHomeFakeDataSource implements DriverHomeDataSource {
  bool _isShiftActive = false;

  bool get isShiftActive => _isShiftActive;

  @override
  Future<DriverStartWorkEntity> getStartWorkOverview() async {
    return const DriverStartWorkEntity(
      isAvailable: false,
      statusLabel: 'غير متاح',
      statusDescription: 'أنت غير متاح لاستلام الطلبات',
      metrics: [
        DriverStartWorkMetricEntity(value: '0.0', label: 'الأرباح'),
        DriverStartWorkMetricEntity(value: '0', label: 'كم تقريباً'),
        DriverStartWorkMetricEntity(value: '0', label: 'طلبات مكتملة'),
      ],
      requirements: [
        DriverStartWorkRequirementEntity(
          id: 'req_checklist',
          title: 'تحقق من متطلبات بدء العمل',
          subtitle: 'راجع المتطلبات المطلوبة',
          type: DriverRequirementType.checklist,
        ),
        DriverStartWorkRequirementEntity(
          id: 'req_pickup',
          title: 'توجه إلى نقطة الاستلام',
          subtitle: 'استلم الصناديق وابدأ التسليم',
          type: DriverRequirementType.pickup,
        ),
        DriverStartWorkRequirementEntity(
          id: 'req_readiness',
          title: 'جاهز لبدء العمل؟',
          subtitle: 'تأكد من جاهزيتك وبدء استقبال الطلبات',
          type: DriverRequirementType.readiness,
        ),
      ],
    );
  }

  @override
  Future<DriverActiveHomeEntity> getActiveHomeOverview() async {
    return const DriverActiveHomeEntity(
      isInDelivery: true,
      currentLocation: 'شارع الخليج العربي ، السالمية',
      goal: DriverDailyGoalEntity(
        completedOrders: 5,
        totalOrdersTarget: 8,
        performanceLevel: 'جيد',
      ),
      currentOrder: DriverCurrentOrderEntity(
        orderId: 'ord_bx_458722',
        orderCode: 'BX-458722',
        clientName: 'محمد علي',
        address: 'شارع الخليج العربي ، قطعة 12 ، منزل 45 ، السالمية',
        mealsCount: 3,
        deliveryTime: '09:20 ص',
        imageAsset: AppAssets.driverBox3d,
      ),
      summary: DriverDailySummaryEntity(
        incompleteCount: 1,
        inDeliveryCount: 2,
        deliveredCount: 5,
        totalOrdersCount: 8,
      ),
      performance: DriverDailyPerformanceEntity(
        averageDeliveryTime: '18 دقيقة',
        distanceCovered: '32.4 كم',
        onTimeRate: '92%',
      ),
    );
  }

  @override
  Future<void> startShift() async {
    _isShiftActive = true;
  }
}
