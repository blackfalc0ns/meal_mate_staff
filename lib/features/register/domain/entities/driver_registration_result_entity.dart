class DriverRegistrationResultEntity {
  const DriverRegistrationResultEntity({
    required this.registrationId,
    required this.restaurantId,
    required this.restaurantName,
    required this.phone,
    required this.status,
    required this.message,
  });

  final String registrationId;
  final String restaurantId;
  final String restaurantName;
  final String phone;
  final String status;
  final String message;
}
