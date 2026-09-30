import '../entities/driver_active_call_entity.dart';
import '../entities/driver_call_attempt_entity.dart';

class DriverCallingFakeData {
  const DriverCallingFakeData._();

  static const DriverActiveCallEntity activeCall = DriverActiveCallEntity(
    customerName: 'محمد علي',
    addressLine: 'شارع الخليج العربي ، قطعة 12 ، منزل 45',
    area: 'السلمانية',
    initialDurationSeconds: 24,
  );

  static const DriverCallAttemptEntity defaultAttempt = DriverCallAttemptEntity(
    customerName: 'محمد علي',
    customerPhone: '+966 50 123 4567',
    attemptNumber: 1,
  );
}
