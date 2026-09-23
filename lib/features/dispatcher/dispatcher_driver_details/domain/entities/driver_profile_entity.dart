import 'driver_details_status.dart';

class DriverProfileEntity {
  const DriverProfileEntity({
    required this.driverId,
    required this.driverCode,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.status,
    required this.statusText,
    this.statusDotColor,
    required this.lastUpdatedText,
  });

  final String driverId;
  final String driverCode;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DriverDetailsStatus status;
  final String statusText;
  final String? statusDotColor;
  final String lastUpdatedText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileEntity &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          driverCode == other.driverCode &&
          fullName == other.fullName &&
          phoneNumber == other.phoneNumber &&
          avatarUrl == other.avatarUrl &&
          status == other.status &&
          statusText == other.statusText &&
          statusDotColor == other.statusDotColor &&
          lastUpdatedText == other.lastUpdatedText;

  @override
  int get hashCode => Object.hash(
    driverId,
    driverCode,
    fullName,
    phoneNumber,
    avatarUrl,
    status,
    statusText,
    statusDotColor,
    lastUpdatedText,
  );
}
