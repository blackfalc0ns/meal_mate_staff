import 'dispatcher_driver_status_type.dart';

class DispatcherDriverStatusItemEntity {
  const DispatcherDriverStatusItemEntity({
    required this.driverId,
    required this.driverCode,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.isAvailable,
    required this.operationalStatus,
    this.rating,
    this.ratingsCount,
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
  });

  final String driverId;
  final String driverCode;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isAvailable;
  final DispatcherDriverStatusType operationalStatus;
  final double? rating;
  final int? ratingsCount;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;

  // Backward compatibility convenience getters
  String get id => driverId;
  String get name => fullName;
  String get code => driverCode;
  String get plateNumber => vehiclePlate ?? '';
  DispatcherDriverStatusType get status => operationalStatus;

  DispatcherDriverStatusItemEntity copyWith({
    String? driverId,
    String? driverCode,
    String? fullName,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    bool? isAvailable,
    DispatcherDriverStatusType? operationalStatus,
    double? rating,
    bool clearRating = false,
    int? ratingsCount,
    bool clearRatingsCount = false,
    String? vehicleType,
    String? vehicleModel,
    String? vehiclePlate,
  }) {
    return DispatcherDriverStatusItemEntity(
      driverId: driverId ?? this.driverId,
      driverCode: driverCode ?? this.driverCode,
      fullName: fullName ?? this.fullName,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      isAvailable: isAvailable ?? this.isAvailable,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      rating: clearRating ? null : (rating ?? this.rating),
      ratingsCount: clearRatingsCount
          ? null
          : (ratingsCount ?? this.ratingsCount),
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverStatusItemEntity &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          driverCode == other.driverCode &&
          fullName == other.fullName &&
          phoneNumber == other.phoneNumber &&
          avatarUrl == other.avatarUrl &&
          isAvailable == other.isAvailable &&
          operationalStatus == other.operationalStatus &&
          rating == other.rating &&
          ratingsCount == other.ratingsCount &&
          vehicleType == other.vehicleType &&
          vehicleModel == other.vehicleModel &&
          vehiclePlate == other.vehiclePlate;

  @override
  int get hashCode => Object.hash(
    driverId,
    driverCode,
    fullName,
    phoneNumber,
    avatarUrl,
    isAvailable,
    operationalStatus,
    rating,
    ratingsCount,
    vehicleType,
    vehicleModel,
    vehiclePlate,
  );
}
