import '../../../../../core/constants/assets.dart';
import '../entities/dispatcher_map_driver_marker_entity.dart';
import '../entities/dispatcher_map_driver_status.dart';
import '../entities/dispatcher_map_kpi_entity.dart';

class DispatcherMapFakeData {
  const DispatcherMapFakeData._();

  static const DispatcherMapKpiEntity kpi = DispatcherMapKpiEntity(
    activeDriversCount: 32,
    inDeliveryCount: 18,
    pausedCount: 7,
    issuesCount: 3,
  );

  static const List<DispatcherMapDriverMarkerEntity> drivers = [
    DispatcherMapDriverMarkerEntity(
      id: 'D-2001',
      name: 'أحمد فيصل',
      boxId: 'BX-452311',
      status: DispatcherMapDriverStatus.onTheWayToLoad,
      locationName: 'الفروانية',
      remainingDistanceKm: 1.8,
      avatarUrl: AppAssets.registrationDriverRole,
      mapRelativeX: 0.30,
      mapRelativeY: 0.44,
    ),
    DispatcherMapDriverMarkerEntity(
      id: 'D-2002',
      name: 'أحمد فيصل',
      boxId: 'BX-452311',
      status: DispatcherMapDriverStatus.inDelivery,
      locationName: 'اليرموك',
      remainingDistanceKm: 1.8,
      avatarUrl: AppAssets.registrationDriverRole,
      mapRelativeX: 0.52,
      mapRelativeY: 0.30,
    ),
    DispatcherMapDriverMarkerEntity(
      id: 'D-2003',
      name: 'يوسف ناصر',
      boxId: 'BX-452311',
      status: DispatcherMapDriverStatus.inDelivery,
      locationName: 'اليرموك',
      remainingDistanceKm: 1.8,
      avatarUrl: AppAssets.registrationDriverRole,
      mapRelativeX: 0.72,
      mapRelativeY: 0.46,
    ),
    DispatcherMapDriverMarkerEntity(
      id: 'D-2004',
      name: 'سعد خالد',
      boxId: 'BX-452311',
      status: DispatcherMapDriverStatus.paused,
      locationName: 'الشعب',
      remainingDistanceKm: null,
      avatarUrl: AppAssets.registrationDriverRole,
      mapRelativeX: 0.46,
      mapRelativeY: 0.54,
    ),
  ];
}
