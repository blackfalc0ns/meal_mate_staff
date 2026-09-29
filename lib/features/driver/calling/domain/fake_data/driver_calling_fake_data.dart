import '../entities/driver_active_call_entity.dart';

class DriverCallingFakeData {
  const DriverCallingFakeData._();

  static const DriverActiveCallEntity activeCall = DriverActiveCallEntity(
    customerName: 'محمد علي',
    addressLine: 'شارع الخليج العربي ، قطعة 12 ، منزل 45',
    area: 'السلمانية',
    initialDurationSeconds: 24,
  );
}
