class RegisterVehicleData {
  const RegisterVehicleData({
    required this.type,
    required this.model,
    required this.manufactureYear,
    required this.plateNumber,
    required this.country,
    required this.color,
    required this.isOwned,
  });

  final String type;
  final String model;
  final String manufactureYear;
  final String plateNumber;
  final String country;
  final String color;
  final bool isOwned;
}
