class DriverProfileEntity {
  const DriverProfileEntity({
    required this.name,
    required this.driverId,
    required this.isOnline,
    this.avatarAsset = 'assets/images/auth/registration_driver_role.png',
    this.appVersion = '2.4.1',
    this.language = 'العربية',
    required this.rating,
    required this.reviewsCount,
    required this.totalOrders,
    required this.acceptanceRate,
    required this.memberSince,
    required this.vehicleType,
    required this.vehicleModel,
    required this.plateNumber,
    required this.isVehicleActive,
    required this.recentTicketId,
    required this.recentTicketSubject,
    required this.recentTicketDate,
    required this.isTicketResolved,
  });

  final String name;
  final String driverId;
  final bool isOnline;
  final String avatarAsset;
  final String appVersion;
  final String language;
  final double rating;
  final int reviewsCount;
  final int totalOrders;
  final int acceptanceRate;
  final String memberSince;
  final String vehicleType;
  final String vehicleModel;
  final String plateNumber;
  final bool isVehicleActive;
  final String recentTicketId;
  final String recentTicketSubject;
  final String recentTicketDate;
  final bool isTicketResolved;
}
