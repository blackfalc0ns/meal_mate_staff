// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_driver_details_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherDriverDetailsResponseDto _$DispatcherDriverDetailsResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverDetailsResponseDto(
  driver: json['driver'] == null
      ? null
      : DispatcherDriverDetailsProfileDto.fromJson(
          json['driver'] as Map<String, dynamic>,
        ),
  today: json['today'] == null
      ? null
      : DispatcherDriverDetailsTodayDto.fromJson(
          json['today'] as Map<String, dynamic>,
        ),
  vehicle: json['vehicle'] == null
      ? null
      : DispatcherDriverDetailsVehicleDto.fromJson(
          json['vehicle'] as Map<String, dynamic>,
        ),
  currentLocation: json['currentLocation'] == null
      ? null
      : DispatcherDriverDetailsLocationDto.fromJson(
          json['currentLocation'] as Map<String, dynamic>,
        ),
  performance: json['performance'] == null
      ? null
      : DispatcherDriverDetailsPerformanceDto.fromJson(
          json['performance'] as Map<String, dynamic>,
        ),
  documents: (json['documents'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherDriverDetailsDocumentDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

DispatcherDriverDetailsProfileDto _$DispatcherDriverDetailsProfileDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverDetailsProfileDto(
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  fullName: json['fullName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  avatarStorageKey: json['avatarStorageKey'] as String?,
  isAvailable: json['isAvailable'] as bool?,
  operationalStatus: json['operationalStatus'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  ratingsCount: (json['ratingsCount'] as num?)?.toInt(),
);

DispatcherDriverDetailsTodayDto _$DispatcherDriverDetailsTodayDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverDetailsTodayDto(
  completedDeliveries: (json['completedDeliveries'] as num?)?.toInt(),
  activeDeliveries: (json['activeDeliveries'] as num?)?.toInt(),
  cashCollected: (json['cashCollected'] as num?)?.toDouble(),
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
);

DispatcherDriverDetailsVehicleDto _$DispatcherDriverDetailsVehicleDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverDetailsVehicleDto(
  vehicleType: json['vehicleType'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
  color: json['color'] as String?,
);

DispatcherDriverDetailsLocationDto _$DispatcherDriverDetailsLocationDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverDetailsLocationDto(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  address: json['address'] as String?,
  updatedAtUtc: json['updatedAtUtc'] as String?,
);

DispatcherDriverDetailsPerformanceDto
_$DispatcherDriverDetailsPerformanceDtoFromJson(Map<String, dynamic> json) =>
    DispatcherDriverDetailsPerformanceDto(
      acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble(),
      onTimeRate: (json['onTimeRate'] as num?)?.toDouble(),
      averageDeliveryMinutes: (json['averageDeliveryMinutes'] as num?)?.toInt(),
      totalDeliveries: (json['totalDeliveries'] as num?)?.toInt(),
    );

DispatcherDriverDetailsDocumentDto _$DispatcherDriverDetailsDocumentDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverDetailsDocumentDto(
  documentType: json['documentType'] as String?,
  documentName: json['documentName'] as String?,
  status: json['status'] as String?,
  expiryDate: json['expiryDate'] as String?,
  documentUrl: json['documentUrl'] as String?,
);
