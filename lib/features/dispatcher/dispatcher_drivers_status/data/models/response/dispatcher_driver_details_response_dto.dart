import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_driver_details_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsResponseDto {
  const DispatcherDriverDetailsResponseDto({
    this.driver,
    this.today,
    this.vehicle,
    this.currentLocation,
    this.performance,
    this.documents,
  });

  factory DispatcherDriverDetailsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriverDetailsResponseDtoFromJson(json);

  final DispatcherDriverDetailsProfileDto? driver;
  final DispatcherDriverDetailsTodayDto? today;
  final DispatcherDriverDetailsVehicleDto? vehicle;
  final DispatcherDriverDetailsLocationDto? currentLocation;
  final DispatcherDriverDetailsPerformanceDto? performance;
  final List<DispatcherDriverDetailsDocumentDto>? documents;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsProfileDto {
  const DispatcherDriverDetailsProfileDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.phoneNumber,
    this.avatarStorageKey,
    this.isAvailable,
    this.operationalStatus,
    this.rating,
    this.ratingsCount,
  });

  factory DispatcherDriverDetailsProfileDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriverDetailsProfileDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarStorageKey;
  final bool? isAvailable;
  final String? operationalStatus;
  final double? rating;
  final int? ratingsCount;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsTodayDto {
  const DispatcherDriverDetailsTodayDto({
    this.completedDeliveries,
    this.activeDeliveries,
    this.cashCollected,
    this.distanceKm,
  });

  factory DispatcherDriverDetailsTodayDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverDetailsTodayDtoFromJson(json);

  final int? completedDeliveries;
  final int? activeDeliveries;
  final double? cashCollected;
  final double? distanceKm;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsVehicleDto {
  const DispatcherDriverDetailsVehicleDto({
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
    this.color,
  });

  factory DispatcherDriverDetailsVehicleDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriverDetailsVehicleDtoFromJson(json);

  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? color;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsLocationDto {
  const DispatcherDriverDetailsLocationDto({
    this.latitude,
    this.longitude,
    this.address,
    this.updatedAtUtc,
  });

  factory DispatcherDriverDetailsLocationDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriverDetailsLocationDtoFromJson(json);

  final double? latitude;
  final double? longitude;
  final String? address;
  final String? updatedAtUtc;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsPerformanceDto {
  const DispatcherDriverDetailsPerformanceDto({
    this.acceptanceRate,
    this.onTimeRate,
    this.averageDeliveryMinutes,
    this.totalDeliveries,
  });

  factory DispatcherDriverDetailsPerformanceDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriverDetailsPerformanceDtoFromJson(json);

  final double? acceptanceRate;
  final double? onTimeRate;
  final int? averageDeliveryMinutes;
  final int? totalDeliveries;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverDetailsDocumentDto {
  const DispatcherDriverDetailsDocumentDto({
    this.documentType,
    this.documentName,
    this.status,
    this.expiryDate,
    this.documentUrl,
  });

  factory DispatcherDriverDetailsDocumentDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriverDetailsDocumentDtoFromJson(json);

  final String? documentType;
  final String? documentName;
  final String? status;
  final String? expiryDate;
  final String? documentUrl;
}
