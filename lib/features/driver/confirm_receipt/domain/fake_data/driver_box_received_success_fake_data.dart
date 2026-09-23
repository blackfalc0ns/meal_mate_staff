import '../entities/driver_box_received_success_entity.dart';

class DriverBoxReceivedSuccessFakeData {
  const DriverBoxReceivedSuccessFakeData._();

  static const DriverBoxReceivedSuccessEntity defaultSuccessBox =
      DriverBoxReceivedSuccessEntity(
        boxCode: '#BX-9876',
        restaurantName: 'مطعم MealMate الكويت',
        itemsCount: 3,
        expectedReceiptTime: '9:30 ص - 9 مايو 2025',
        isReceived: true,
      );
}
