import '../entities/dispatcher_driver_entity.dart';
import '../entities/dispatcher_driver_status.dart';
import '../entities/dispatcher_drivers_kpi_entity.dart';

class DispatcherDriversFakeData {
  const DispatcherDriversFakeData._();

  static const List<String> areas = [
    'السالمية',
    'حولي',
    'حطين',
    'الفروانية',
    'العاصمة',
  ];

  static const DispatcherDriversKpiEntity kpi = DispatcherDriversKpiEntity(
    totalDrivers: 13,
    availableDrivers: 8,
    busyNow: 5,
  );

  static const List<DispatcherDriverEntity> drivers = [
    // Salmiya (8 drivers: 5 available, 2 on the way, 1 on break)
    DispatcherDriverEntity(
      id: 'D-1025',
      name: 'أحمد محمد',
      rating: 4.9,
      status: DispatcherDriverStatus.available,
      area: 'السالمية',
      currentOrdersCount: 1,
      completedOrdersTodayCount: 12,
      distanceKm: 9.0,
    ),
    DispatcherDriverEntity(
      id: 'D-1044',
      name: 'محمد العتيبي',
      rating: 4.9,
      status: DispatcherDriverStatus.available,
      area: 'السالمية',
      currentOrdersCount: 0,
      completedOrdersTodayCount: 8,
      distanceKm: 9.0,
    ),
    DispatcherDriverEntity(
      id: 'D-1045',
      name: 'محمد علي',
      rating: 4.8,
      status: DispatcherDriverStatus.onTheWay,
      area: 'السالمية',
      currentOrdersCount: 2,
      completedOrdersTodayCount: 9,
      distanceKm: 11.5,
    ),
    DispatcherDriverEntity(
      id: 'D-1046',
      name: 'فهد العنزي',
      rating: 4.7,
      status: DispatcherDriverStatus.onBreak,
      area: 'السالمية',
      currentOrdersCount: 0,
      completedOrdersTodayCount: 10,
      distanceKm: 14.0,
    ),
    DispatcherDriverEntity(
      id: 'D-1047',
      name: 'سالم الكندري',
      rating: 4.9,
      status: DispatcherDriverStatus.available,
      area: 'السالمية',
      currentOrdersCount: 1,
      completedOrdersTodayCount: 14,
      distanceKm: 7.2,
    ),
    DispatcherDriverEntity(
      id: 'D-1048',
      name: 'عبدالله الرشيدي',
      rating: 4.8,
      status: DispatcherDriverStatus.available,
      area: 'السالمية',
      currentOrdersCount: 0,
      completedOrdersTodayCount: 7,
      distanceKm: 8.5,
    ),
    DispatcherDriverEntity(
      id: 'D-1049',
      name: 'خالد المطيري',
      rating: 4.6,
      status: DispatcherDriverStatus.available,
      area: 'السالمية',
      currentOrdersCount: 1,
      completedOrdersTodayCount: 11,
      distanceKm: 10.0,
    ),
    DispatcherDriverEntity(
      id: 'D-1050',
      name: 'ناصر الشمري',
      rating: 4.7,
      status: DispatcherDriverStatus.onTheWay,
      area: 'السالمية',
      currentOrdersCount: 3,
      completedOrdersTodayCount: 6,
      distanceKm: 12.8,
    ),

    // Hawally
    DispatcherDriverEntity(
      id: 'D-1051',
      name: 'يوسف الحربي',
      rating: 4.9,
      status: DispatcherDriverStatus.available,
      area: 'حولي',
      currentOrdersCount: 0,
      completedOrdersTodayCount: 9,
      distanceKm: 5.4,
    ),
    DispatcherDriverEntity(
      id: 'D-1052',
      name: 'عمر القحطاني',
      rating: 4.8,
      status: DispatcherDriverStatus.onTheWay,
      area: 'حولي',
      currentOrdersCount: 2,
      completedOrdersTodayCount: 13,
      distanceKm: 6.8,
    ),

    // Hateen
    DispatcherDriverEntity(
      id: 'D-1053',
      name: 'بدر الدوسري',
      rating: 4.9,
      status: DispatcherDriverStatus.available,
      area: 'حطين',
      currentOrdersCount: 1,
      completedOrdersTodayCount: 15,
      distanceKm: 8.0,
    ),

    // Farwaniya
    DispatcherDriverEntity(
      id: 'D-1054',
      name: 'سعود الهاجري',
      rating: 4.7,
      status: DispatcherDriverStatus.onBreak,
      area: 'الفروانية',
      currentOrdersCount: 0,
      completedOrdersTodayCount: 5,
      distanceKm: 16.0,
    ),

    // Capital
    DispatcherDriverEntity(
      id: 'D-1055',
      name: 'مشعل السبيعي',
      rating: 4.9,
      status: DispatcherDriverStatus.available,
      area: 'العاصمة',
      currentOrdersCount: 0,
      completedOrdersTodayCount: 10,
      distanceKm: 4.2,
    ),
  ];
}
