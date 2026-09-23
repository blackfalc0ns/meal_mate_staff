import '../../../../../core/constants/assets_fake.dart';
import '../entities/active_delivery_location_entity.dart';
import '../entities/active_delivery_order_entity.dart';
import '../entities/active_delivery_trip_entity.dart';
import '../entities/delivery_failure_reason_entity.dart';
import '../entities/delivery_trip_status.dart';
import '../entities/return_box_entity.dart';

class DriverActiveDeliveryFakeData {
  const DriverActiveDeliveryFakeData._();

  static const ActiveDeliveryOrderEntity defaultOrder =
      ActiveDeliveryOrderEntity(
        orderId: '#MM-987654',
        boxCode: '#BX-1256',
        customerName: 'عبدالله العتيبي',
        customerPhone: '+965 9876 5432',
        customerAvatar: AssetsFake.customerAvatar,
        address: 'قطعة 6 ، شارع الخليج العربي ، برج الرؤية',
        mealsCount: 3,
        customerNote: 'يرجى الاتصال قبل الوصول والضغط على جرس الباب',
        restaurantName: 'مطعم برجر ميت',
        restaurantAddress: 'السالمية ، شارع سالم المبارك',
        paymentMethod: 'مدفوع مسبقاً (KNET)',
      );

  static const ActiveDeliveryLocationEntity initialDriverLocation =
      ActiveDeliveryLocationEntity(
        latitude: 29.3759,
        longitude: 47.9774,
        heading: 45.0,
        speed: 35.0,
      );

  static const ActiveDeliveryLocationEntity customerLocation =
      ActiveDeliveryLocationEntity(latitude: 29.3850, longitude: 48.0050);

  static const ActiveDeliveryLocationEntity restaurantLocation =
      ActiveDeliveryLocationEntity(latitude: 29.3375, longitude: 48.0750);

  static const List<ActiveDeliveryLocationEntity> simulatedRoutePoints = [
    ActiveDeliveryLocationEntity(
      latitude: 29.3759,
      longitude: 47.9774,
      heading: 45.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3775,
      longitude: 47.9810,
      heading: 50.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3790,
      longitude: 47.9860,
      heading: 55.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3810,
      longitude: 47.9910,
      heading: 60.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3825,
      longitude: 47.9960,
      heading: 60.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3840,
      longitude: 48.0010,
      heading: 65.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3850,
      longitude: 48.0050,
      heading: 70.0,
    ),
  ];

  static const List<ActiveDeliveryLocationEntity> returnRoutePoints = [
    ActiveDeliveryLocationEntity(
      latitude: 29.3850,
      longitude: 48.0050,
      heading: 140.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3750,
      longitude: 48.0200,
      heading: 140.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3600,
      longitude: 48.0400,
      heading: 135.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3480,
      longitude: 48.0600,
      heading: 130.0,
    ),
    ActiveDeliveryLocationEntity(
      latitude: 29.3375,
      longitude: 48.0750,
      heading: 125.0,
    ),
  ];

  static const List<DeliveryFailureReasonEntity> failureReasons = [
    DeliveryFailureReasonEntity(
      id: 'no_answer',
      title: 'العميل لا يجيب على الهاتف',
      description: 'تم الاتصال أكثر من 3 مرات دون استجابة',
    ),
    DeliveryFailureReasonEntity(
      id: 'wrong_address',
      title: 'العنوان غير صحيح أو غير واضح',
      description: 'الموقع الفعلي مختلف أو غير محدد بدقة',
    ),
    DeliveryFailureReasonEntity(
      id: 'customer_refused',
      title: 'العميل رفض استلام الطلب',
      description: 'رفض العميل لأسباب تتعلق بالوقت أو محتوى الطلب',
    ),
    DeliveryFailureReasonEntity(
      id: 'damaged_box',
      title: 'مشكلة في الصندوق أو الوجبة',
      description: 'تضرر الصندوق أو انسكاب المحتويات أثناء النقل',
    ),
    DeliveryFailureReasonEntity(
      id: 'other',
      title: 'أخرى (مع كتابة ملاحظة)',
      description: 'يرجى توضيح السبب في الملاحظات',
    ),
  ];

  static const ActiveDeliveryTripEntity defaultTrip = ActiveDeliveryTripEntity(
    tripId: 'TRIP-78912',
    order: defaultOrder,
    status: DeliveryTripStatus.readyToStart,
    driverLocation: initialDriverLocation,
    customerLocation: customerLocation,
    restaurantLocation: restaurantLocation,
    routePoints: simulatedRoutePoints,
    estimatedMinutes: 15,
    distanceKm: 4.2,
  );

  static ReturnBoxEntity createReturnBox({
    required String failureReason,
    String? note,
    String? attachmentPath,
  }) {
    return ReturnBoxEntity(
      boxCode: defaultOrder.boxCode,
      restaurantName: defaultOrder.restaurantName,
      restaurantAddress: defaultOrder.restaurantAddress,
      restaurantLocation: restaurantLocation,
      failureReason: failureReason,
      note: note,
      attachmentPath: attachmentPath,
    );
  }
}
