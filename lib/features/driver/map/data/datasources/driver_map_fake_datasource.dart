import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';

import '../../../orders/domain/entities/driver_delivery_status.dart';
import '../../domain/entities/driver_map_stop_entity.dart';

class DriverMapFakeDataSource {
  const DriverMapFakeDataSource._();

  static const LatLng driverInitialLocation = LatLng(29.3320, 48.0820);

  static const List<LatLng> sampleRoutePoints = [
    LatLng(29.3320, 48.0820),
    LatLng(29.3340, 48.0790),
    LatLng(29.3355, 48.0775),
    LatLng(29.3375, 48.0753), // Stop 1
    LatLng(29.3400, 48.0710),
    LatLng(29.3430, 48.0680),
    LatLng(29.3450, 48.0650), // Stop 2
    LatLng(29.3480, 48.0600),
    LatLng(29.3520, 48.0550), // Stop 3
  ];

  static const List<DriverMapStopEntity> sampleStops = [
    DriverMapStopEntity(
      id: 'stop_1',
      boxCode: 'BX-458722',
      sequenceNumber: 1,
      totalStops: 3,
      customerName: 'محمد علي',
      customerPhone: '',
      area: 'السالمية',
      formattedAddress: 'شارع الخليج العربي ، قطعة 12 ، منزل 45 ، السالمية',
      mealsCount: 3,
      deliveryTimeSlot: '20 : 09 ص',
      status: DriverDeliveryStatus.inProgress,
      latitude: 29.3375,
      longitude: 48.0753,
      imageAsset: AppAssets.driverKpiBox,
    ),
    DriverMapStopEntity(
      id: 'stop_2',
      boxCode: 'BX-458722',
      sequenceNumber: 2,
      totalStops: 3,
      customerName: 'مهند أحمد',
      customerPhone: '',
      area: 'السالمية',
      formattedAddress: 'السالمية ، شارع 512 ، عمارة 10',
      mealsCount: 3,
      deliveryTimeSlot: '20 : 09 ص',
      status: DriverDeliveryStatus.inProgress,
      latitude: 29.3450,
      longitude: 48.0650,
      imageAsset: AppAssets.driverKpiBox,
    ),
    DriverMapStopEntity(
      id: 'stop_3',
      boxCode: 'BX-458722',
      sequenceNumber: 3,
      totalStops: 3,
      customerName: 'أحمد فيصل',
      customerPhone: '',
      area: 'السالمية',
      formattedAddress: 'السالمية ، شارع 512 ، مجمع الأمل',
      mealsCount: 3,
      deliveryTimeSlot: '20 : 09 ص',
      status: DriverDeliveryStatus.delivered,
      latitude: 29.3520,
      longitude: 48.0550,
      imageAsset: AppAssets.driverKpiBox,
    ),
  ];
}
