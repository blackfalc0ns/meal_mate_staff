import 'package:meal_mate_delivery/core/constants/assets.dart';

import '../entities/driver_active_box_entity.dart';
import '../entities/driver_details_entity.dart';

class DriverDetailsFakeData {
  const DriverDetailsFakeData._();

  static const DriverDetailsEntity defaultDriver = DriverDetailsEntity(
    id: 'DR-1025',
    name: 'أحمد السعيد',
    phone: '+966 50 123 4567',
    isAvailable: true,
    lastUpdate: 'الآن',
    currentBoxesCount: 2,
    deliveredTodayCount: 28,
    avgDelayMinutes: 12,
    performanceRating: 4.8,
    locationStatus: 'خارج للتوصيل',
    locationTimeAgoMinutes: 15,
    locationStreet: 'شارع الملك فهد',
    locationArea: 'حي العليا، الرياض',
    approxKm: 120,
    failedDeliveryCount: 1,
    activeBoxes: [
      DriverActiveBoxEntity(
        boxId: '#BX-10256',
        customerName: 'محمد الفضلي',
        area: 'السليمانية، الرياض',
        status: 'خارج للتوصيل',
        time: '12:30 م',
        imageAsset: AppAssets.driverBox3d,
        isDelivering: true,
      ),
      DriverActiveBoxEntity(
        boxId: '#BX-10256',
        customerName: 'نورة الدوسري',
        area: 'السليمانية، الرياض',
        status: 'تم الاستلام',
        time: '12:30 م',
        imageAsset: AppAssets.driverBox3d,
        isDelivering: false,
      ),
    ],
  );
}
