import '../entities/driver_profile_entity.dart';
import '../entities/driver_profile_ticket_entity.dart';
import '../entities/driver_profile_vehicle_entity.dart';

class DriverProfileFakeData {
  const DriverProfileFakeData._();

  static const DriverProfileEntity defaultProfile = DriverProfileEntity(
    driverProfileId: '1256',
    fullName: 'أحمد إبراهيم',
    driverDescription: 'سائق معتمد',
    driverCode: 'MM-1256',
    isOnline: true,
    status: 'Active',
    statusText: 'نشط',
    averageRating: 4.8,
    reviewsCount: 124,
    totalOrders: 128,
    acceptanceRatePercent: 94.0,
    vehicle: DriverProfileVehicleEntity(
      vehicleType: 'سيارة',
      vehicleModel: 'هيونداي إلنترا',
      vehicleYear: 2021,
      plateNumber: 'أ ص ب - 1234',
      isVehicleActive: true,
    ),
    latestSupportTicket: DriverProfileTicketEntity(
      ticketId: '4587',
      ticketNumber: 'SUP-4587',
      subject: 'استفسار عن دفعة أسبوعية',
      body: 'استفسار عن دفعة أسبوعية',
      status: 'Resolved',
      statusText: 'تم الحل',
    ),
  );
}

