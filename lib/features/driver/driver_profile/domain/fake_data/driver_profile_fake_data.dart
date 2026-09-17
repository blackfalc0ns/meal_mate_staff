import '../entities/driver_profile_entity.dart';

class DriverProfileFakeData {
  const DriverProfileFakeData._();

  static const DriverProfileEntity defaultProfile = DriverProfileEntity(
    name: 'أحمد إبراهيم',
    driverId: '#MM-1256',
    isOnline: true,
    rating: 4.8,
    reviewsCount: 124,
    totalOrders: 128,
    acceptanceRate: 94,
    memberSince: 'مارس 2024',
    vehicleType: 'سيارة',
    vehicleModel: 'هيونداي إلنترا 2021',
    plateNumber: 'أ ص ب - 1234',
    isVehicleActive: true,
    recentTicketId: '#SUP-4587',
    recentTicketSubject: 'استفسار عن دفعة أسبوعية',
    recentTicketDate: '24 مايو 2025',
    isTicketResolved: true,
  );
}
