import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_drivers_status_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDriversStatusResponseDto {
  const DispatcherDriversStatusResponseDto({
    this.counts,
    this.items,
    this.pagination,
  });

  factory DispatcherDriversStatusResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriversStatusResponseDtoFromJson(json);

  final DispatcherDriversStatusCountsDto? counts;
  final List<DispatcherDriverStatusItemDto>? items;
  final DispatcherDriversPaginationDto? pagination;
}

@JsonSerializable(createToJson: false)
class DispatcherDriversStatusCountsDto {
  const DispatcherDriversStatusCountsDto({
    this.total,
    this.available,
    this.inDelivery,
    this.unavailable,
  });

  factory DispatcherDriversStatusCountsDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDriversStatusCountsDtoFromJson(json);

  final int? total;
  final int? available;
  final int? inDelivery;
  final int? unavailable;
}

@JsonSerializable(createToJson: false)
class DispatcherDriverStatusItemDto {
  const DispatcherDriverStatusItemDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.phoneNumber,
    this.avatarStorageKey,
    this.isAvailable,
    this.operationalStatus,
    this.rating,
    this.ratingsCount,
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
  });

  factory DispatcherDriverStatusItemDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriverStatusItemDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarStorageKey;
  final bool? isAvailable;
  final String? operationalStatus;
  final double? rating;
  final int? ratingsCount;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;
}

@JsonSerializable(createToJson: false)
class DispatcherDriversPaginationDto {
  const DispatcherDriversPaginationDto({
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.totalPages,
    this.hasPreviousPage,
    this.hasNextPage,
  });

  factory DispatcherDriversPaginationDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherDriversPaginationDtoFromJson(json);

  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final int? totalPages;
  final bool? hasPreviousPage;
  final bool? hasNextPage;
}
