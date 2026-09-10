import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_home_alert_entity.dart';
import '../entities/dispatcher_home_area_summary_entity.dart';
import '../entities/dispatcher_home_kpi_entity.dart';
import '../entities/dispatcher_home_map_driver_pin_entity.dart';
import '../entities/dispatcher_home_operations_status_entity.dart';
import '../entities/dispatcher_home_quick_action_entity.dart';
import '../entities/dispatcher_home_top_driver_entity.dart';

class DispatcherHomeFakeData {
  const DispatcherHomeFakeData._();

  static const List<DispatcherHomeKpiItemEntity> kpiItems = [
    DispatcherHomeKpiItemEntity(
      id: 'kpi_total_orders',
      label: 'إجمال الطلبات\nاليوم',
      value: '128',
      iconAsset: AppAssets.dispatcherHomeKpiBox,
      accentColorType: DispatcherHomeKpiColorType.purple,
    ),
    DispatcherHomeKpiItemEntity(
      id: 'kpi_in_delivery',
      label: 'في التوصيل',
      value: '58',
      iconAsset: AppAssets.dispatcherHomeKpiTruck,
      accentColorType: DispatcherHomeKpiColorType.blue,
    ),
    DispatcherHomeKpiItemEntity(
      id: 'kpi_pending',
      label: 'بانتظار الإسناد',
      value: '23',
      iconAsset: AppAssets.dispatcherHomeKpiClock,
      accentColorType: DispatcherHomeKpiColorType.orange,
    ),
    DispatcherHomeKpiItemEntity(
      id: 'kpi_issues',
      label: 'مشاكل حالية',
      value: '2',
      iconAsset: AppAssets.dispatcherHomeKpiInfo,
      accentColorType: DispatcherHomeKpiColorType.red,
    ),
  ];

  static const List<DispatcherHomeQuickActionEntity> quickActions = [
    DispatcherHomeQuickActionEntity(
      type: DispatcherHomeQuickActionType.assignDriver,
      title: 'تعيين سائق',
      iconAsset: AppAssets.dispatcherHomeActionAssignDriver,
    ),
    DispatcherHomeQuickActionEntity(
      type: DispatcherHomeQuickActionType.solveIssues,
      title: 'حل المشكلات',
      iconAsset: AppAssets.dispatcherHomeActionSolveIssues,
    ),
    DispatcherHomeQuickActionEntity(
      type: DispatcherHomeQuickActionType.driversMap,
      title: 'خريطة السائقين',
      iconAsset: AppAssets.dispatcherHomeActionDriversMap,
    ),
    DispatcherHomeQuickActionEntity(
      type: DispatcherHomeQuickActionType.allDrivers,
      title: 'كل السائقين',
      iconAsset: AppAssets.dispatcherHomeActionAllDrivers,
    ),
  ];

  static const List<DispatcherHomeMapDriverPinEntity> mapDriverPins = [
    DispatcherHomeMapDriverPinEntity(
      id: 'pin_1',
      boxCode: 'BX-458622',
      statusText: 'في التوصيل',
      status: DispatcherHomePinStatus.inDelivery,
      avatarUrl: AppAssets.registrationDriverRole,
      relativeX: 0.35,
      relativeY: 0.22,
    ),
    DispatcherHomeMapDriverPinEntity(
      id: 'pin_2',
      boxCode: 'BX-458622',
      statusText: 'في التوصيل',
      status: DispatcherHomePinStatus.inDelivery,
      avatarUrl: AppAssets.registrationDriverRole,
      relativeX: 0.70,
      relativeY: 0.50,
    ),
    DispatcherHomeMapDriverPinEntity(
      id: 'pin_3',
      boxCode: 'BX-458622',
      statusText: 'في الطريق للتحميل',
      status: DispatcherHomePinStatus.onTheWayToLoad,
      avatarUrl: AppAssets.registrationDriverRole,
      relativeX: 0.15,
      relativeY: 0.42,
    ),
    DispatcherHomeMapDriverPinEntity(
      id: 'pin_4',
      boxCode: 'BX-458622',
      statusText: 'متوقف',
      status: DispatcherHomePinStatus.paused,
      avatarUrl: AppAssets.registrationDriverRole,
      relativeX: 0.44,
      relativeY: 0.55,
    ),
  ];

  static const DispatcherHomeOperationsStatusEntity operationsStatus =
      DispatcherHomeOperationsStatusEntity(
    completionRate: 87,
    deliveredCount: 112,
    deliveredLabel: 'تم التوصيل',
    inDeliveryCount: 58,
    inDeliveryLabel: 'في التوصيل',
    pendingCount: 23,
    pendingLabel: 'بانتظار الإسناد',
    cancelledCount: 7,
    cancelledLabel: 'تم الإلغاء',
  );

  static const List<DispatcherHomeTopDriverEntity> topDrivers = [
    DispatcherHomeTopDriverEntity(
      id: 'driver_1',
      name: 'أحمد السعيد',
      badgeText: 'أعلى تقييم',
      rating: 4.9,
      avatarUrl: AppAssets.registrationDriverRole,
    ),
    DispatcherHomeTopDriverEntity(
      id: 'driver_2',
      name: 'محمد العنزي',
      badgeText: 'تقييم ممتاز',
      rating: 4.1,
      avatarUrl: AppAssets.registrationDriverRole,
    ),
    DispatcherHomeTopDriverEntity(
      id: 'driver_3',
      name: 'يوسف خالد',
      badgeText: 'تقييم جيد جداً',
      rating: 3.2,
      avatarUrl: AppAssets.registrationDriverRole,
    ),
  ];

  static const List<DispatcherHomeAreaSummaryEntity> areaSummaries = [
    DispatcherHomeAreaSummaryEntity(
      id: 'area_salmiya',
      name: 'السالمية',
      ordersCount: 38,
      isIncreasing: true,
      colorType: DispatcherHomeAreaColorType.salmiya,
    ),
    DispatcherHomeAreaSummaryEntity(
      id: 'area_hawally',
      name: 'حولي',
      ordersCount: 32,
      isIncreasing: true,
      colorType: DispatcherHomeAreaColorType.hawally,
    ),
    DispatcherHomeAreaSummaryEntity(
      id: 'area_jahra',
      name: 'الجهراء',
      ordersCount: 18,
      isIncreasing: false,
      colorType: DispatcherHomeAreaColorType.jahra,
    ),
    DispatcherHomeAreaSummaryEntity(
      id: 'area_capital',
      name: 'العاصمة',
      ordersCount: 16,
      isIncreasing: false,
      colorType: DispatcherHomeAreaColorType.capital,
    ),
  ];

  static const DispatcherHomeAlertEntity alert = DispatcherHomeAlertEntity(
    id: 'alert_1',
    title: 'هناك 2 مشكلة تحتاج إلى انتباهك',
    description: 'تأخير في التوصيل . سائق متوقف منذ فترة طويلة',
  );
}
