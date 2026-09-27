// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_drivers_status_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherDriversStatusResponseDto _$DispatcherDriversStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriversStatusResponseDto(
  counts: json['counts'] == null
      ? null
      : DispatcherDriversStatusCountsDto.fromJson(
          json['counts'] as Map<String, dynamic>,
        ),
  items: (json['items'] as List<dynamic>?)
      ?.map(
        (e) =>
            DispatcherDriverStatusItemDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : DispatcherDriversPaginationDto.fromJson(
          json['pagination'] as Map<String, dynamic>,
        ),
);

DispatcherDriversStatusCountsDto _$DispatcherDriversStatusCountsDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriversStatusCountsDto(
  total: (json['total'] as num?)?.toInt(),
  available: (json['available'] as num?)?.toInt(),
  inDelivery: (json['inDelivery'] as num?)?.toInt(),
  unavailable: (json['unavailable'] as num?)?.toInt(),
);

DispatcherDriverStatusItemDto _$DispatcherDriverStatusItemDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriverStatusItemDto(
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  fullName: json['fullName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  avatarStorageKey: json['avatarStorageKey'] as String?,
  isAvailable: json['isAvailable'] as bool?,
  operationalStatus: json['operationalStatus'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  ratingsCount: (json['ratingsCount'] as num?)?.toInt(),
  vehicleType: json['vehicleType'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
);

DispatcherDriversPaginationDto _$DispatcherDriversPaginationDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDriversPaginationDto(
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalItems: (json['totalItems'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  hasPreviousPage: json['hasPreviousPage'] as bool?,
  hasNextPage: json['hasNextPage'] as bool?,
);
